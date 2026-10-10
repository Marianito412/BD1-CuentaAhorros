import { Avatar, Badge, Card, Group, NumberFormatter, Stack, Title } from "@mantine/core";
import userSession from "../core/Session";

function BeneficiaryCard() {
  return (
    <Card>
      <Stack>
        <Group align="flex-start">
          <Avatar size="xl" radius="lg" key={"Test"} name={"Masd fasd"} color="initials"/>

          <Stack>
            <Title>Mariano Soto</Title>
            <Group justify="space-between">
              <Title order={4}>
                <NumberFormatter value={100.3} suffix="%" />
              </Title>
              <Badge>Padre</Badge>
            </Group>
          </Stack>
        </Group>

      </Stack>
    </Card>
  );
}

function BeneficiariesPage() {
  return (
    <Stack h="70vh" w="100vw" align="center" justify="center" gap="md">
      <Group justify="center">
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
        <BeneficiaryCard/>
      </Group>
    </Stack>
  );
}

export default BeneficiariesPage;