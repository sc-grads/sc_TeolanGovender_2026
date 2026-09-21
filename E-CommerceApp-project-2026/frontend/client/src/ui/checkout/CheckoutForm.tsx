import { useEffect, useState } from "react";
import {PaymentElement, useElements, useStripe} from "@stripe/react-stripe-js";
import { config } from "../../../config";

type CheckoutFormProps = {
  amount: number;
  onPaymentSuccess: () => Promise<void>;
  onClose: () => void;
};

const CheckoutForm = ({amount, onPaymentSuccess, onClose}: CheckoutFormProps) => {
  const stripe = useStripe();
  const elements = useElements();
  const [clientSecret, setClientSecret] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetch(`${config.baseUrl}/create-payment-intent`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${localStorage.getItem("access_token")}`,
      },
    })
      .then((res) => res.json())
      .then((data) => setClientSecret(data.clientSecret));
  }, [amount]);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoading(true);

    await elements!.submit();

    await stripe!.confirmPayment({
      elements: elements!,
      clientSecret,
      confirmParams: { return_url: window.location.href },
      redirect: "if_required",
    });

    await onPaymentSuccess();
    onClose();
  };

  if (!clientSecret) return <div>Loading payment...</div>;

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <PaymentElement />
      <button type="submit" disabled={loading} className="w-full bg-black text-white py-3 rounded-lg">
        {loading ? "Processing..." : `Pay R${amount.toFixed(2)}`}
      </button>
    </form>
  );
};

export default CheckoutForm;