import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const ForgotPassword = () => {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleReset = async (e: React.FormEvent) => {
    e.preventDefault();

    setMessage("");
    setError("");
    setLoading(true);

    try {
      const response = await fetch(
        `${config.baseUrl}/forgot-password`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ email }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        setError(data.message || "Something went wrong.");
        return;
      }

      setMessage(
        "A temporary password has been sent to your email. Please use it to log in and then change your password."
      );
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md bg-white rounded-xl shadow-md border border-gray-200 p-8">

        <div className="text-center mb-8">
          <h1 className="text-3xl font-semibold text-darkText">
            Reset Password
          </h1>

          <p className="text-gray-500 mt-2">
            Enter your email to receive a temporary password.
          </p>
        </div>

        <form onSubmit={handleReset} className="space-y-5">

          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Email
            </label>

            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="Enter your email"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {error && (
            <p className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-md p-3">
              {error}
            </p>
          )}

          {message && (
            <p className="text-sm text-green-600 bg-green-50 border border-green-200 rounded-md p-3">
              {message}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-darkText text-white py-2.5 rounded-md font-medium hover:bg-gray-800 transition disabled:opacity-50"
          >
            {loading ? "Sending..." : "Send Temporary Password"}
          </button>

        </form>

        <div className="text-center mt-6">
          <button
            type="button"
            onClick={() => navigate("/login")}
            className="text-sky-600 font-medium hover:underline"
          >
            Back to Login
          </button>
        </div>

      </div>
    </div>
  );
};

export default ForgotPassword;