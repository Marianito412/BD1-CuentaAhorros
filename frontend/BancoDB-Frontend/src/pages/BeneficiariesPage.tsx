import {
    Avatar,
    Badge,
    Card,
    Group,
    Modal,
    NumberFormatter,
    Select, Slider,
    Stack,
    TextInput,
    Title,
    Text, Button, Space
} from "@mantine/core";
import userSession from "../core/Session";
import {DateInput} from "@mantine/dates";
import {Form, useParams} from "react-router";
import {useDisclosure} from "@mantine/hooks";
import {useNavigate} from "react-router";
import {useEffect, useState} from "react";
import { useForm } from '@mantine/form';

type beneficiary = {
    //Persona
    TipoDocuIdentidad: number
    NombreDocuIdentidad: string,
    Nombre: string,
    Email: string,
    Telefono: string,
    Telefono2: string,
    FechaNacimiento: string,

    //Beneficiario
    Id: number,
    IdBeneficiario: string,
    IdParentezco: number,
    NombreParentezco: string,
    Porcentaje: number,
    flagActivo: boolean,
}

function BeneficiaryCard({b, p}: {b: beneficiary, p:any[]}) {
    const [opened, {open, close}] = useDisclosure(false)
    const navigate = useNavigate();

    const form = useForm({
        initialValues: {
            Id: b.Id ?? 0,
            Nombre: '',
            NombreParentezco: '',
            IdParentezco: 0,
            NombreDocuIdentidad: '',
            IdBeneficiario: '',
            Porcentaje: 0,
            Email: '',
            Telefono: '',
            Telefono2: '',
        },
        /*
        validate: {
            Email: (value) => (/^\S+@\S+$/.test(value) ? null : 'Invalid email'),
        },
         */
    });
    
    useEffect(() => {
        if (!b) return;
        form.setValues({
            Id: b.Id ?? 0,
            Nombre: b.Nombre ?? '',
            NombreDocuIdentidad: b.NombreDocuIdentidad ?? '',
            IdBeneficiario: b.IdBeneficiario ?? '',
            NombreParentezco: b.NombreParentezco ?? '',
            IdParentezco: b.IdParentezco ?? 0,
            Porcentaje: b.Porcentaje ?? 0,
            Email: b.Email ?? '',
            Telefono: b.Telefono ?? '',
            Telefono2: b.Telefono2 ?? '',
        });
        form.resetDirty();
        //console.log("Data ", form.values)
        //console.log("Input", b)
    },[b])

    /*
    async function submitChange(values: typeof form.values){
        const result = await fetch("/api/updateAccountBeneficiary/", {
            method: "POST",
            
            body: values
        })
        const data = await result.json()
        console.log(data)
    }
    */
    
    const handleSubmit = async (values: typeof form.values) => {
        //await onSave({ ...beneficiaryData, ...values }); // your API call
        
        const request = {
            Id: b.Id,
            Porcentaje: values.Porcentaje,
            Nombre: values.Nombre,
            IdParentezco: values.IdParentezco
        }
        
        const result = await fetch("/api/updateAccountBeneficiary", {
            method: "POST",

            body: JSON.stringify(request),
            headers: {
                "Content-Type": "application/json",
            },
        })
        const data = await result.json()
        console.log(data)
        close();
        navigate(0)
    };
    
    async function deleteBeneficiario() {
        console.log("delete beneficiario", form.values.Id);
        const result = await fetch("/api/deleteBeneficiario", {
            method: "POST",
            body: JSON.stringify({"Id": form.values.Id}),
            headers: {
                "Content-Type": "application/json",
            },
        })
        const data = await result.json()
        console.log(data)
        close()
        navigate(0)
    }
    
    return (
        <>
            <Card component="a" onClick={open} style={{cursor: "pointer"}}>
                <Stack>
                    <Group align="flex-start">
                        <Avatar size="xl" radius="lg" key={"Test"} name={b.Nombre} color="initials"/>

                        <Stack>
                            <Title>{b.Nombre}</Title>
                            <Group justify="space-between">
                                <Title order={4}>
                                    <NumberFormatter value={b.Porcentaje} suffix="%"/>
                                </Title>
                                <Badge>{b.NombreParentezco}</Badge>
                            </Group>
                        </Stack>
                    </Group>
                </Stack>
            </Card>

            <Modal opened={opened} onClose={close}>
                <Form onSubmit={form.onSubmit(handleSubmit)}>
                    <Select label="Tipo de identinficación" disabled {...form.getInputProps("NombreDocuIdentidad")}
                    data={["", form.values.NombreDocuIdentidad]}/>
                    <TextInput label="Identificación" disabled {...form.getInputProps("IdBeneficiario")}></TextInput>
                    <DateInput label="Fecha de nacimiento" disabled/>

                    <TextInput label="Nombre" {...form.getInputProps('Nombre')}/>
                    <Select
                        label="Parentezco"
                        data={p.map((a) => a.Nombre)}
                        {...form.getInputProps('NombreParentezco')}
                    />

                    <Text size="sm" mt="xl">Porcentaje de beneficio</Text>
                    <Slider color="blue" 
                            value={form.values.Porcentaje}
                            onChange={(v) => form.setFieldValue('Porcentaje', v)}
                    />

                    <TextInput label="Email" {...form.getInputProps('Email')}></TextInput>
                    <TextInput label="Teléfono 1" {...form.getInputProps('Telefono')}></TextInput>
                    <TextInput label="Teléfono 2" {...form.getInputProps('Telefono2')}></TextInput>

                    <Space h="md"/>
                    <Group wrap="nowrap">
                        <Button fullWidth type="submit">Guardar</Button>
                        <Button color="red" variant="outline" fullWidth onClick={close}>Cancelar</Button>
                    </Group>
                    <Space h="md"/>
                    <Button fullWidth color="red" onClick={deleteBeneficiario}>Eliminar</Button>
                </Form>
            </Modal>

        </>
    );
}

/*
const testData: beneficiary[] = [
    {
        Id: 0,
        Nombre: "Mariano Soto",
        TipoDocuIdentidad: 1,
        NombreDocuIdentidad: "Cedula",
        IdParentezco: 1,
        NombreParentezco: "Padre",
        Porcentaje: 65,
        Email: "test@gmail.com",
        FechaNacimiento: "12/5/2002",
        flagActivo: true,
        IdBeneficiario: "121235324",
        Telefono:"1234-1234",
        Telefono2:"1234-1234",
    }
]
*/

function NuevoBeneficiarioForm(){
    const [opened, {open, close}] = useDisclosure(false)
    
    return(
        <>
            <Button>Agregar</Button>
            <Modal opened={opened} onClose={close}>
                
            </Modal>
        </>
    );
}

function BeneficiariesPage() {
    const {accountId} = useParams()
    const [beneficiaries, setBeneficiaries] = useState<beneficiary[]>([])
    const [parentescos, setParentescos] = useState([])

    useEffect(() => {
        fetchParentescos()
            .then(() => {fetchBeneficiaries()})
    }, [])
    
    async function fetchBeneficiaries(){
        const result = await fetch("/api/getAccountBeneficiaries/"+accountId)
        const data = await result.json()
        setBeneficiaries(data)
        //console.log(data)
    }
    
    async function fetchParentescos(){
        const result = await fetch("/api/getParentescos")
        const data = await result.json()
        setParentescos(data)
    }

    return (
        <Stack mt="50px" h="70vh" w="100vw" align="center" justify="center" gap="md">
            <Stack align="stretch">
                <Group justify="space-between">
                    <Title>Beneficiarios</Title>
                    {beneficiaries.length < 3 ? <NuevoBeneficiarioForm/> : null}
                </Group>
                
                {beneficiaries.map(
                    (bData) => <BeneficiaryCard b={bData} p={parentescos} />
                )}
            </Stack>
        </Stack>
    );
}

export default BeneficiariesPage;