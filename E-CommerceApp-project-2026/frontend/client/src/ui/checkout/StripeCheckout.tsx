"use client";

import { Elements } from "@stripe/react-stripe-js";
import { loadStripe } from "@stripe/stripe-js";
import CheckoutForm from "./CheckoutForm";
import convertCurrency from "../../lib/ConvertCurrency";

const stripePromise = loadStripe(
  import.meta.env.VITE_STRIPE_PUBLIC_KEY
);

type Props = {
  amount: number;
  onPaymentSuccess: (paymentIntentId: string) => Promise<void>;
  onClose: () => void;
};

const StripeCheckout = ({
  amount,
  onPaymentSuccess,
  onClose,
}: Props) => {
  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-md">

        <h2 className="text-2xl font-semibold mb-4">Secure Payment</h2>

        <Elements stripe={stripePromise}options={{mode: "payment", amount: convertCurrency(amount), currency: "zar",}}>
          <CheckoutForm amount={amount} onPaymentSuccess={onPaymentSuccess} onClose={onClose}/>
        </Elements>
      </div>
    </div>
  );
};

export default StripeCheckout;