import axios from "axios";

const API = "http://localhost:3000";

export const getPrices = () => axios.get(`${API}/price`);
export const getETHBalance = () => axios.get(`${API}/balance/eth`);
export const getBTC = () => axios.get(`${API}/btc`);
export const getTokens = () => axios.get(`${API}/tokens`);
