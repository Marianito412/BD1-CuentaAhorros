import { createBrowserRouter, RouterProvider } from "react-router-dom";
import LoginPage from "./pages/LoginPage.tsx";
import MainPage from "./pages/MainPage.tsx";
import BeneficiariesPage from "./pages/BeneficiariesPage.tsx";
import StatementsPage from "./pages/StatementsPage.tsx";

const router = createBrowserRouter([
  {
    path: "/",
    element: <MainPage />,
  },
  {
    path: "/login",
    element: <LoginPage />,
  },
  {
    path: "/beneficiaries/:accountNumber",
    element: <BeneficiariesPage />,
  },
  {
    path: "/statements/:accountNumber",
    element: <StatementsPage />,
  },
]);

export function Router() {
  return <RouterProvider router={router} />;
}
