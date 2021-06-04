import React from 'react';
import Web3 from 'web3';
import './App.css';
import Color from '../abis/Color.json';

const App = () => {
  const input = React.useRef();
  const [account, setAccount] = React.useState('');
  const [contract, setContract] = React.useState(null);
  const [totalSupply, setTotalSupply] = React.useState(0);
  const [colors, setColors] = React.useState([]);

  async function loadWeb3() {
    if(window.ethereum){
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    }else if(window.web3){
      window.web3 = new Web3(window.web3.currentProvider);
    }else {
      window.alert("이더리움이 없습니다. 메타마스크를 이용해보세요!")
    }
  }

  async function loadBlockchainData() {
    const web3 = window.web3;
    try{
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      const networkId = await web3.eth.net.getId(); // 가나슈의 network id
      const networkData = Color.networks[networkId]; // abis/Color.json에 보면 networks 안에 address 값이 있음.

      if(networkData){
        const address = networkData.address; // 네트워크 주소값
        const abi = Color.abi; // abi는 계약내용? 같음

        // contract를 가져오기 위해선 abi, 주소가 필요함
        const newContract = new web3.eth.Contract(abi, address);
        setContract(newContract);

        const newTotalSupply = await newContract.methods.totalSupply().call();
        setTotalSupply(newTotalSupply);

        let newColors = [];
        for(let i = 1; i <= newTotalSupply; i++){
          const color = await newContract.methods.colors(i - 1).call();
          newColors = newColors.concat(color);
        }
        setColors(newColors);
      }else{
        window.alert('스마트 컨트랙트가 네트워크에 배포되어 있지 않으므로 사용 할 수 없습니다.')
      }
    }catch(e){
      console.log(e);
      window.alert("예기치 못한 에러 발생")
    }
  }

  function handleSubmit(e) {
    e.preventDefault();
    const { value } = input.current;
    const valueArray = value.split("#");
    
    if(!value){
      alert("색상을 입력해주세요.");
      return;
    }
    if(value.length !== 7){
      alert("색상은 #을 포함하여 총 7자리여야 합니다.");
      return;
    }
    if(valueArray.length === 1){
      alert("색상에는 반드시 #이 포함되어야 합니다.");
      return;
    }
    if(valueArray.length > 2){
      alert("#은 한 개만 포함 될 수 있습니다.");
      return;
    }
    if(valueArray[0] !== ""){
      alert("색상은 반드시 #으로 시작해야 합니다.");
      return;
    }

    const colorCheck = colors.find(color => color === value);
    if(colorCheck){
      alert("이미 등록되어 있는 색상을 Mint 할 순 없습니다.");
      return;
    }

    mint(value);
  }

  function mint(color){
    contract.methods.mint(color).send({from: account})
    .on('transactionHash', hash => {
      console.log("hash >", hash);
      setColors([...colors, color])
    }).on('error', function (error) {
      console.log("error >", error)
      if(error.code !== 4001){
        alert("예기치 못한 에러가 발생하여 Mint가 종료되었습니다.")
      }
    }).on('receipt', receipt => {
      console.log("receipt >", receipt);
    });
  }

  async function start() {
    await loadWeb3();
    await loadBlockchainData();
  }

  React.useEffect(() => {
    start();
  }, [])

  return (
    <div>
      <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
        <a
          className="navbar-brand col-sm-3 col-md-2 mr-0"
          href="http://www.dappuniversity.com/bootcamp"
          target="_blank"
          rel="noopener noreferrer"
        >
          Color Token
        </a>
        <ul className="navbar-nav px-3">
          <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
            <small className="text-white">
              <span id="account">{account}</span>
            </small>
          </li>
        </ul>
      </nav>
      <div className="container-fluid mt-5">
        <div className="row">
          <main role="main" className="col-lg-12 d-flex text-center">
            <div className="content mr-auto ml-auto">
              <h1>Issue Token</h1>
              <form onSubmit={handleSubmit}>
                <input
                  type="text"
                  className="form-control mb-1"
                  placeholder="#FFFFFF"
                  ref={input}
                />
                <input
                  type="submit"
                  className="btn btn-block btn-primary"
                  value="Mint"
                />
              </form>
            </div>
          </main>
        </div>
        <hr />
        <div className="row text-center">
          {colors.map((color, index) => {
            return (
              <div key={index} className="col-md-3 mb-3">
                <div className="token" style={{backgroundColor: color}} />
                <div>{color}</div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  );
};

export default App;