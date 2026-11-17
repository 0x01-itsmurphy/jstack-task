export const DEMO_USER = Object.freeze({
  id: 'USR10001',
  name: 'Demo User',
  email: 'demo@jstack.co',
  password: 'Demo@123',
});

export const DEMO_WALLET = Object.freeze({
  walletId: 'WALLET10001',
  userId: 'USR10001',
  currency: 'INR',
  balancePaise: 2_545_075,
  maskedAccountNumber: 'XXXX XXXX 4589',
});

const txn = (id, type, amountPaise, beneficiaryName, mobileNumber, status, createdAt, remarks = null) =>
  Object.freeze({
    id,
    walletId: DEMO_WALLET.walletId,
    type,
    amountPaise,
    currency: 'INR',
    beneficiaryName,
    mobileNumber,
    status,
    remarks,
    createdAt,
  });

export const SEED_TRANSACTIONS = Object.freeze([
  txn('TXN10001', 'DEBIT', 150_000, 'Rahul Sharma', '9876543210', 'SUCCESS', '2026-10-20T10:30:00Z', 'Payment for services'),
  txn('TXN10002', 'CREDIT', 500_000, 'Amit Kumar', '9812345670', 'SUCCESS', '2026-10-19T14:15:00Z', 'Loan repayment'),
  txn('TXN10003', 'DEBIT', 34_900, 'Priya Verma', '9123456780', 'SUCCESS', '2026-10-22T08:45:00Z', 'Movie tickets'),
  txn('TXN10004', 'CREDIT', 200_000, 'Neha Gupta', '9988776655', 'SUCCESS', '2026-10-24T18:20:00Z', 'Split dinner bill'),
  txn('TXN10005', 'DEBIT', 79_950, 'Vikas Singh', '9090909090', 'FAILED', '2026-10-26T12:05:00Z', 'Mobile recharge'),
  txn('TXN10006', 'DEBIT', 420_000, 'Sneha Patel', '9822012345', 'SUCCESS', '2026-10-28T09:10:00Z', 'Rent share'),
  txn('TXN10007', 'CREDIT', 1_200_000, 'Rohit Mehta', '9765432109', 'SUCCESS', '2026-11-01T11:00:00Z'),
  txn('TXN10008', 'DEBIT', 25_000, 'Anjali Rao', '9654321098', 'PENDING', '2026-11-03T16:40:00Z', 'Groceries'),
  txn('TXN10009', 'DEBIT', 199_900, 'Karan Malhotra', '9543210987', 'SUCCESS', '2026-11-06T13:25:00Z', 'Gym membership'),
  txn('TXN10010', 'CREDIT', 75_025, 'Pooja Nair', '9432109876', 'SUCCESS', '2026-11-09T19:55:00Z', 'Refund'),
  txn('TXN10011', 'DEBIT', 310_000, 'Arjun Reddy', '9321098765', 'SUCCESS', '2026-11-12T07:30:00Z', 'Electricity bill'),
  txn('TXN10012', 'CREDIT', 150_000, 'Kavita Joshi', '9210987654', 'SUCCESS', '2026-11-15T15:10:00Z'),
]);
