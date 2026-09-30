import {createBrowserRouter, RouterProvider} from 'react-router';
import LoginPage from './pages/LoginPage.tsx';
import MainPage from './pages/MainPage.tsx';
import BeneficiariesPage from './pages/BeneficiariesPage.tsx';
import StatementsPage from './pages/StatementsPage.tsx';

const router = createBrowserRouter([
    {
        path: '/',
        element: <MainPage/>
    },
    {
        path: '/login',
        element: <LoginPage/>
    },
    {
        path: '/beneficiaries',
        element: <BeneficiariesPage/>
    },
    {
        path: '/statements',
        element: <StatementsPage/>
    }
]);

export function Router() {
    return <RouterProvider router={router}/>;
}