import React, { useContext, useRef, useState } from "react";
import { DeployedContext } from "../App";

const RegisterModal = ({ setRegister }) => {
  const { deployed, account, CA, web3 } = useContext(DeployedContext);
  const [isChecked, SetIsChecked] = useState(true);
  const value1 = useRef();
  const value2 = useRef();
  const value3 = useRef();
  const value4 = useRef();
  const register = async () => {
    const name = value1.current.value.toString();
    const price = value2.current.value;
    const num = value3.current.value;
    const typeIs = value4.current.checked ? "BUY" : "SELL";
    if (!name || !price || !num) {
      alert("모든 값을 입력해주세요.");
      return;
    }
    if (typeIs === "BUY") {
      await deployed.methods
        .registerFruit(name, price, num, typeIs)
        .send({
          from: account,
          to: CA,
          value: web3.utils.toWei(String(price * num), "ether"),
        });
    } else {
      await deployed.methods
        .registerFruit(name, price, num, typeIs)
        .send({ from: account });
    }

    setRegister(false);
  };
  return (
    <div className="registerModal">
      <div className="buySellBtns">
        <label htmlFor="BUY">구매</label>
        <input
          id="BUY"
          type="checkbox"
          value="BUY"
          checked={isChecked}
          onChange={() => {
            SetIsChecked(!isChecked);
          }}
          ref={value4}
        />{" "}
        <label htmlFor="SELL">판매</label>
        <input
          id="SELL"
          value="SELL"
          type="checkbox"
          checked={!isChecked}
          onChange={() => {
            SetIsChecked(!isChecked);
          }}
        />
      </div>
      <div className="registerDiv">
        과일 이름 : <input type="text" ref={value1} />
      </div>
      <div className="registerDiv">
        {isChecked ? "구매" : "판매"} 수량 :{" "}
        <input type="number" ref={value3} />
      </div>
      <div className="registerDiv">
        {isChecked ? "구매" : "판매"} 가격 :{" "}
        <input type="number" ref={value2} />
      </div>
      <div className="registerBtns">
        <button
          onClick={() => {
            setRegister(false);
          }}
        >
          취소
        </button>
        <button onClick={register}>등록</button>
      </div>
    </div>
  );
};

export default RegisterModal;
