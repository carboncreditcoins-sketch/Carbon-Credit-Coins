import express from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { ethers } from "ethers";

const app = express();
app.use(express.json());

let users = [];

/* =========================
AUTH
========================= */
app.post("/register", async (req, res) => {
  const { email, password } = req.body;

  const hash = await bcrypt.hash(password, 10);

  users.push({ email, password: hash });

  res.json({ status: "ok" });
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  const user = users.find(u => u.email === email);
  if (!user) return res.status(400).send("User not found");

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(400).send("Invalid");

  const token = jwt.sign({ email }, "SECRET");

  res.json({ token });
});
