import {
  Button,
  Card,
  PasswordInput,
  Space,
  Stack,
  Text,
  TextInput,
  Title,
} from "@mantine/core";

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import userSession from "../core/Session";

function LoginPage() {
  const navigate = useNavigate();

  const [user, setUser] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit() {
    setError("");

    if (!user || !password) {
      setError("Ingrese el usuario y la contraseña.");
      return;
    }

    setLoading(true);

    try {
      const success = await userSession.tryLogin(user, password);

      if (success) {
        navigate("/");
      } else {
        setError("Usuario o contraseña incorrectos.");
      }
    } catch (error) {
      console.error(error);
      setError("No fue posible conectar con el servidor.");
    } finally {
      setLoading(false);
    }
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
          placeholder="Usuario"
          value={user}
          onChange={(e) => {
            setUser(e.currentTarget.value);
          }}
        />

        <PasswordInput
          label="Contraseña"
          placeholder="Contraseña"
          value={password}
          onChange={(e) => {
            setPassword(e.currentTarget.value);
          }}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              onSubmit();
            }
          }}
        />

        <Space h="md" />

        {error && (
          <>
            <Text c="red">{error}</Text>
            <Space h="sm" />
          </>
        )}

        <Button variant="filled" onClick={onSubmit} loading={loading}>
          Iniciar Sesión
        </Button>
      </Card>
    </Stack>
  );
}

export default LoginPage;
