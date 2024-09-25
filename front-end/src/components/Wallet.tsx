interface WalletProps {
  text: string;
}

const Wallet: React.FC<WalletProps> = ({ text = "hi" }) => {
  return (
    <h1>
      <w3m-button />
    </h1>
  );
};
export default Wallet;
