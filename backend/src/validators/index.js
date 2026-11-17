import { ApiError } from '../utils/api-error.js';
import { hasAtMostTwoDecimals } from '../utils/money.js';

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export const MOBILE_RE = /^[6-9]\d{9}$/;

const isNonEmptyString = (v) => typeof v === 'string' && v.trim().length > 0;

const throwIfErrors = (fieldErrors) => {
  if (Object.keys(fieldErrors).length > 0) {
    throw ApiError.validation('One or more fields are invalid.', { fieldErrors });
  }
};

export const validateLogin = (body = {}) => {
  const errors = {};
  if (!isNonEmptyString(body.email)) errors.email = 'Email is required.';
  else if (!EMAIL_RE.test(body.email.trim())) errors.email = 'Enter a valid email address.';
  if (!isNonEmptyString(body.password)) errors.password = 'Password is required.';
  throwIfErrors(errors);
  return { email: body.email.trim(), password: body.password };
};

export const validateTransfer = (body = {}) => {
  const errors = {};
  const { beneficiaryName, mobileNumber, amount, remarks } = body;

  if (!isNonEmptyString(beneficiaryName)) errors.beneficiaryName = 'Beneficiary name is required.';
  else if (beneficiaryName.trim().length > 100) errors.beneficiaryName = 'Beneficiary name is too long.';

  if (!isNonEmptyString(mobileNumber)) errors.mobileNumber = 'Mobile number is required.';
  else if (!MOBILE_RE.test(mobileNumber.trim())) errors.mobileNumber = 'Enter a valid 10-digit mobile number.';

  if (amount === undefined || amount === null || amount === '') errors.amount = 'Amount is required.';
  else if (typeof amount !== 'number' || !Number.isFinite(amount)) errors.amount = 'Amount must be a number.';
  else if (amount <= 0) errors.amount = 'Amount must be greater than zero.';
  else if (!hasAtMostTwoDecimals(amount)) errors.amount = 'Amount can have at most 2 decimal places.';

  if (remarks !== undefined && remarks !== null) {
    if (typeof remarks !== 'string') errors.remarks = 'Remarks must be text.';
    else if (remarks.trim().length > 200) errors.remarks = 'Remarks must be 200 characters or fewer.';
  }

  throwIfErrors(errors);
  return {
    beneficiaryName: beneficiaryName.trim(),
    mobileNumber: mobileNumber.trim(),
    amount,
    remarks: remarks?.trim() || null,
  };
};

const TXN_TYPES = ['CREDIT', 'DEBIT'];

export const validateTransactionQuery = (query = {}) => {
  const errors = {};
  const type = query.type?.toString().toUpperCase();
  if (type && !TXN_TYPES.includes(type)) errors.type = 'Type must be CREDIT or DEBIT.';

  const page = query.page === undefined ? 1 : Number(query.page);
  if (!Number.isInteger(page) || page < 1) errors.page = 'Page must be a positive integer.';

  const limit = query.limit === undefined ? 20 : Number(query.limit);
  if (!Number.isInteger(limit) || limit < 1 || limit > 100) errors.limit = 'Limit must be between 1 and 100.';

  const parseDate = (value, field) => {
    if (value === undefined) return null;
    const date = new Date(value.toString());
    if (Number.isNaN(date.getTime())) errors[field] = `${field} must be a valid ISO-8601 date.`;
    return date;
  };
  const from = parseDate(query.from, 'from');
  const to = parseDate(query.to, 'to');

  throwIfErrors(errors);
  return { type, search: query.search?.toString().trim() || null, page, limit, from, to };
};
