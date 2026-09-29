import "react-multi-carousel/lib/styles.css";
import Header from "./ui/Header";
import Footer from "./ui/Footer";
import AppRoutes from "./routes/Routes";
import { useLocation } from "react-router-dom";

function App() {
  const location = useLocation();

  const hideHeader =
    location.pathname === "/login" ||
    location.pathname === "/register";

  return (
    <main>
      {!hideHeader && <Header />}

      <AppRoutes />

      <Footer />
    </main>
  );
}

export default App;