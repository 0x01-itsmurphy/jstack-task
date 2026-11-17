export const toPaise = (rupees) => Math.round(rupees * 100);

export const toRupees = (paise) => paise / 100;

export const hasAtMostTwoDecimals = (value) =>
  Math.abs(value * 100 - Math.round(value * 100)) < 1e-6;
