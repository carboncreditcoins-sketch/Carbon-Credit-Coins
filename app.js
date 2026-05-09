import { useState } from "react";
import axios from "axios";

function App() {
  const [to, setTo] = useState("");
  const [amount, setAmount] = useState("");

  const send = async () => {
    const res = await axios.post("http://localhost:3000/send", {
      to,
      amount
    });

    alert(JSON.stringify(res.data));
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>CCC Dashboard</h2>

      <input placeholder="Destino" onChange={e => setTo(e.target.value)} />
      <input placeholder="Quantidade" onChange={e => setAmount(e.target.value)} />

      <button onClick={send}>Enviar</button>
    </div>
  );
}

export default App;
