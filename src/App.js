import { useEffect, useState } from "react";
import { getPrices, getETHBalance, getBTC } from "./services/api";
import Header from "./components/Header";
import BalanceCard from "./components/BalanceCard";
import PriceCard from "./components/PriceCard";
import Chart from "./components/Chart";
import "./styles.css";

export default function App() {
  const [prices, setPrices] = useState({});
  const [eth, setEth] = useState(0);
  const [btc, setBtc] = useState(0);

  useEffect(() => {
    getPrices().then(res => setPrices(res.data));
    getETHBalance().then(res => setEth(res.data.eth));
    getBTC().then(res => setBtc(res.data.balance));
  }, []);

  return (
    <div className="app">
      <Header />

      <div className="grid">
        <BalanceCard title="ETH Balance" value={eth} />
        <BalanceCard title="BTC Balance" value={btc} />
      </div>

      <div className="grid">
        <PriceCard name="Bitcoin" price={prices.bitcoin?.usd} />
        <PriceCard name="Ethereum" price={prices.ethereum?.usd} />
      </div>

      <Chart />
    </div>
  );
}
