type OrderSummaryProps = {
  total: number;
  itemCount: number;
  onCheckout: () => void;
};

const OrderSummary = ({
  total,
  itemCount,
  onCheckout,
}: OrderSummaryProps) => {
  return (
    <div className="bg-white rounded-xl border p-6 h-fit sticky top-24">
      <h2 className="text-xl font-semibold mb-6">Order Summary</h2>

      <div className="flex justify-between mb-4">
        <span>Items:</span>
        <span>{itemCount}</span>
      </div>

      <div className="flex justify-between mb-6">
        <span>Total:</span>
        <span className="font-bold text-xl">R {total.toFixed(2)} </span>
      </div>

      <button onClick={onCheckout}className="w-full bg-greenText text-white py-3 rounded-lg hover:bg-skyText transition"> Checkout </button>
    </div>
  );
};

export default OrderSummary;