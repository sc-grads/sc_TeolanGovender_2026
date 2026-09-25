import { useEffect, useState } from "react";
import {
  PaymentElement,
  useElements,
  useStripe,
} from "@stripe/react-stripe-js";
import { config } from "../../../config";

type CheckoutFormProps = {
  amount: number;
  onPaymentSuccess: (paymentIntentId: string) => Promise<void>;
  onClose: () => void;
};

const CheckoutForm = ({
  amount,
  onPaymentSuccess,
  onClose,
}: CheckoutFormProps) => {
  const stripe = useStripe();
  const elements = useElements();

  const [clientSecret, setClientSecret] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    fetch(`${config.baseUrl}/create-payment-intent`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${localStorage.getItem("access_token")}`,
      },
    })
      .then((res) => res.json())
      .then((data) => {
        setClientSecret(data.clientSecret);
      });
  }, [amount]);

  const handleSubmit = async (
    event: React.FormEvent<HTMLFormElement>
  ) => {
    event.preventDefault();

    if (!stripe || !elements) {
      return;
    }

    setLoading(true);
    setErrorMessage("");

    // Validate the PaymentElement fields first
    const { error: submitError } = await elements.submit();

    if (submitError) {
      setErrorMessage(
        submitError.message || "Please check your card details."
      );
      setLoading(false);
      return;
    }

    // Attempt the actual Stripe payment
    const { error, paymentIntent } = await stripe.confirmPayment({
      elements,
      clientSecret,
      confirmParams: {
        return_url: window.location.href,
      },
      redirect: "if_required",
    });

    // Stripe rejected the payment
    if (error) {
      setErrorMessage(
        error.message || "Your payment was declined."
      );
      setLoading(false);
      return;
    }

    // Make absolutely sure the PaymentIntent succeeded
    if (!paymentIntent || paymentIntent.status !== "succeeded") {
      setErrorMessage(
        "Your payment could not be completed."
      );
      setLoading(false);
      return;
    }

    try {
      // Only now do we create the order
      await onPaymentSuccess(paymentIntent.id);

      onClose();
    } catch (error) {
      console.error("Order creation failed:", error);

      setErrorMessage(
        "Payment succeeded, but we could not create your order. Please contact support."
      );

      setLoading(false);
    }
  };

  if (!clientSecret) {
    return <div>Loading payment...</div>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <PaymentElement />

      {errorMessage && (
        <div className="border border-red-300 bg-red-50 text-red-700 rounded-lg p-3">
          <p className="font-semibold">Transaction Failed</p>
          <p className="text-sm mt-1">{errorMessage}</p>
        </div>
      )}

      <div className="flex gap-3">
        <button
          type="button"
          onClick={onClose}
          disabled={loading}
          className="w-1/3 border border-gray-300 py-3 rounded-lg"
        >
          Cancel
        </button>

        <button
          type="submit"
          disabled={loading || !stripe || !elements}
          className="w-2/3 bg-black text-white py-3 rounded-lg disabled:opacity-50"
        >
          {loading
            ? "Processing..."
            : `Pay R${amount.toFixed(2)}`}
        </button>
      </div>
    </form>
  );
};

export default CheckoutForm;

