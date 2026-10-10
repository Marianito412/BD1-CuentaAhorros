import {Badge, Card, Group, NumberFormatter, Stack, Title, Text, Menu} from "@mantine/core";
import {useNavigate} from "react-router";
import userSession from "../core/Session";
import {useEffect, useState} from "react";

type AccountInfo = {
    saldo: number;
    tipoCuenta: string;
    numCuenta: string;
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
                            <Text fw={500}>{info.tipoCuenta}</Text>
                            <Badge><Text fw={500}>{info.numCuenta}</Text></Badge>
                        </Group>
                    </Card.Section>

                    <Title fw={500}>
                        <NumberFormatter prefix="₡" value={info.saldo} thousandSeparator/>
                    </Title>

                    {/* <Group>
          <ActionIcon>
            <InvoiceIcon style={{ width: '70%', height: '70%' }}/>
          </ActionIcon>
          <ActionIcon>
            <UserListIcon style={{ width: '70%', height: '70%' }}/>
          </ActionIcon>
        </Group>
         */}

                </Card>
            </Menu.Target>

            <Menu.Dropdown>
                <Menu.Item onClick={() => navigate("/statements")}>
                    Estados de cuenta
                </Menu.Item>

                <Menu.Item onClick={() => navigate("/beneficiaries")}>
                    Beneficiarios
                </Menu.Item>
            </Menu.Dropdown>

        </Menu>
    );
}

const Accounts: AccountInfo[] = [
    {saldo: 123450, tipoCuenta: "Proletario", numCuenta: "1234-2132"},
    {saldo: 4328650, tipoCuenta: "Profesional", numCuenta: "9324-4264"},
    {saldo: 85700, tipoCuenta: "Proletario", numCuenta: "4385-6343"}
]

function MainPage() {
    
    
    async function getAccounts() {
        const response = await fetch("/api/getAccounts/" + userSession.getUserName(), {method: "Get"})
        let data: any;
        data = await response.json();
        return data
    }

    useEffect(() => {
        const test = getAccounts()
    }, [])

    return (
        <Stack w="100vw" align="center" justify="center" gap="md">
            <Group mt={50}>
                {Accounts.map((acc) => <AccountCard info={acc}/>)}
            </Group>
        </Stack>
    );
}

export default MainPage