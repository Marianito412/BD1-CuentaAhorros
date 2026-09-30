import {
  Button,
  Card,
  PasswordInput,
  Space,
  Stack,
  TextInput,
  Title,
} from "@mantine/core";
import { useState } from "react";

function LoginPage() {
  const [user, setUser] = useState("");
  let [password, setPassword] = useState("");

  async function onSubmit() {
    console.log("Usuario: " + user + "\nContraseña: " + password);

    const response = await fetch("http://127.0.0.1:5000/api/login", {
      method: "POST",
      body: JSON.stringify({
        user: user,
        password: password,
      }),

      headers: {
        "Content-Type": "application/json",
      },
    });
    if (!response.ok){
      console.log("Http ERROR: "+response.status);
    }

    console.log(response.json());
  }

  return (
    <Stack h="70vh" w="100vw" align="center" justify="center" gap="md">
      <Stack>
        <Title>¡Bienvenido a BanquitoCR!</Title>
      </Stack>
      <Space h="lg" />

      <Card w={600}>
        <TextInput
          label="Usuario"
          placeholder="John Doe"
          onChange={(e) => {
            setUser(e.currentTarget.value);
          }}
        />

        <PasswordInput
          label="Contraseña"
          placeholder="Una contraseña fuerte"
          onChange={(e) => {
            setPassword(e.currentTarget.value);
          }}
        />
        <Space h="md" />

        <Button variant="filled" onClick={onSubmit}>
          Inciar Sesión
        </Button>
      </Card>
    </Stack>
  );
}

export default LoginPage;
