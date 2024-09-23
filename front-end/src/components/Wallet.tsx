interface WalletProps {
  text: string;
}

const Wallet: React.FC<WalletProps> = ({ text = "hi" }) => {
  return <h1>{text}</h1>;
};
export default Wallet;
