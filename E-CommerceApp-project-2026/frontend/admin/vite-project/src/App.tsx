import "react-multi-carousel/lib/styles.css";
import Header from "./ui/Header";
import Footer from "./ui/Footer";
import AppRoutes from "./routes/Routes";

function App() {
  return (
    <main>
      <Header />

      <AppRoutes />

      <Footer />
    </main>
  );
}

export default App;