export const sendSuccess = (res, data, meta) => {
  const body = { success: true, data };
  if (meta) body.meta = meta;
  return res.status(200).json(body);
};
