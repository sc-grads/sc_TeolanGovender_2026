import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const Login = () => {
  const [loading, setLoading] = useState(false);
  const [errMsg, setErrMsg] = useState("");

  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setErrMsg("");

    const formData = new FormData(e.currentTarget);

    const email = formData.get("email") as string;
    const password = formData.get("password") as string;

    try {
      setLoading(true);

      const response = await fetch(`${config.baseUrl}/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          password,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
      throw new Error(data.message || "Invalid email or password.");
    }
    
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);
    localStorage.setItem("user", JSON.stringify(data.user));
    
    window.dispatchEvent(new Event("authChange"));
    
    console.log("Login successful");
    
    navigate("/");
    } catch (error) {
      console.error("Login error:", error);

      if (error instanceof Error) {
        setErrMsg(error.message);
      } else {
        setErrMsg("An error occurred. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md bg-white rounded-xl shadow-md border border-gray-200 p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-semibold text-darkText">
            Welcome Back
          </h1>

          <p className="text-gray-500 mt-2">
            Login to your Tech Traders account
          </p>
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
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
              name="email"
              required
              placeholder="Enter your email"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          <div>
            <label
              htmlFor="password"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Password
            </label>

            <input
              id="password"
              type="password"
              name="password"
              required
              placeholder="Enter your password"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {errMsg && (
            <p className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-md p-3">
              {errMsg}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-darkText text-white py-2.5 rounded-md font-medium hover:bg-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>

        <div className="text-center mt-6">
          <p className="text-sm text-gray-500">
            Don't have an account?{" "}
            <button
              type="button"
              onClick={() => navigate("/register")}
              className="text-sky-600 font-medium hover:underline"
            >
              Register
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;