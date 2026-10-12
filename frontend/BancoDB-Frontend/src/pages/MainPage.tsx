import {Badge, Card, Group, NumberFormatter, Stack, Title, Text, Menu} from "@mantine/core";
import {useNavigate} from "react-router";
import userSession from "../core/Session";
import {useEffect, useState} from "react";

type AccountInfo = {
    Saldo: number;
    TipoCuenta: string;
    Simbolo: string;
    Moneda: string;
    NumeroCuenta: string;
}

function AccountCard({info}: { info: AccountInfo }) {
    const navigate = useNavigate();

    console.log(userSession.getUserName())

    return (
        <Menu>
            <Menu.Target>
                <Card shadow="lg" w={300} style={{cursor: "pointer"}}>

                    <Card.Section withBorder inheritPadding py="xs">
                        <Group justify="space-between">
                            <Text fw={500}>{info.TipoCuenta}</Text>
                            <Badge><Text fw={500}>{info.NumeroCuenta}</Text></Badge>
                        </Group>
                    </Card.Section>

                    <Title fw={500}>
                        <NumberFormatter prefix={info.Simbolo} value={info.Saldo} thousandSeparator/>
                    </Title>

                </Card>
            </Menu.Target>

            <Menu.Dropdown>
                <Menu.Item onClick={() => navigate("/statements")}>
                    Estados de cuenta
                </Menu.Item>

                <Menu.Item onClick={() => navigate("/"+info.NumeroCuenta+"/beneficiaries")}>
                    Beneficiarios
                </Menu.Item>
            </Menu.Dropdown>

        </Menu>
    );
}

function MainPage() {
    const [accounts, setAccounts] = useState<AccountInfo[]>([]);
    
    async function fetchAccounts() {
        const response = await fetch("/api/getAccounts/" + userSession.getUserName(), {method: "Get"})
        let data: any;
        data = await response.json();
        setAccounts(data["accounts"]);
        //return data
    }

    useEffect(() => {
        fetchAccounts();
    }, [])

    return (
        <Stack w="100vw" align="center" justify="center" gap="md">
            <Group mt={50}>
                {accounts.map((acc) => <AccountCard info={acc}/>)}
            </Group>
        </Stack>
    );
}

export default MainPage