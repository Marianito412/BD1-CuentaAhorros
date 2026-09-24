import {createBrowserRouter, RouterProvider} from 'react-router';
import App from "./App.tsx"

const router = createBrowserRouter([
    {
        path: '/',
        element: <App/>
    },
    {
        path: '/test',
        element: <h1>This is a test</h1>
    }
]);

export function Router() {
    return <RouterProvider router={router}/>;
}