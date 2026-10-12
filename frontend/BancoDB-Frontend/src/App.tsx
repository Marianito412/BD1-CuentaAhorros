import './index.css'
import '@mantine/core/styles.css';
import '@mantine/dates/styles.css';
import { MantineProvider } from '@mantine/core';
import { Router } from './Router';

export default function App() {
    return (
        <MantineProvider forceColorScheme="dark">
            <Router/>
        </MantineProvider>
    );
}