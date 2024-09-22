// pages/api/logExample.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(_req: NextApiRequest, res: NextApiResponse) {
  console.log("Logging this from an API route!");
  res.status(200).json({ message: 'Logged in terminal!' });
}
