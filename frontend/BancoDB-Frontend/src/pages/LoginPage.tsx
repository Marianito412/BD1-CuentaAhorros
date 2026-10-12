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
import userSession from "../core/Session";
import { useNavigate } from "react-router";

function LoginPage() {
  const navigate = useNavigate();
  const [user, setUser] = useState("");
  let [password, setPassword] = useState("");

  async function onSubmit() {
    //console.log("Usuario: " + user + "\nContraseña: " + password);

    //http://127.0.0.1:5000/api/login
    const success = await userSession.tryLogin(user, password)

    if (success)
    {
      navigate("/")
    }
    /*
    const response = await fetch("/api/login", {
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

    const body = await response.json()
    console.log(body)
    if (body["success"]){
      console.log("Success")
    }
    console.log(response.json());
    */
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
