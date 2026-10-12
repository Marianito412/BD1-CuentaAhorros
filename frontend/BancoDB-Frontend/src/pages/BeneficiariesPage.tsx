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
    Text, Button, Space, Alert
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

type Parentesco = {
    Id: number,
    Nombre: string,
}

type DocId = {
    Id: number,
    Nombre: string,
}

function getParentescoId(parentescos: Parentesco[], nombre: string) {
    const encontrado = parentescos.find(p => p.Nombre === nombre);
    return encontrado ? encontrado.Id : null;
}

function getDocId(Docs: DocId[], nombre: string) {
    const encontrado = Docs.find(p => p.Nombre === nombre);
    return encontrado ? encontrado.Id : null;
}

function BeneficiaryCard({b, p}: {b: beneficiary, p:any[]}) {
    const {accountNumber} = useParams()
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
        validate: {
            Nombre: (v) => {
                const s = v.trim();
                if (!s) return 'El nombre es obligatorio';
                if (s.length > 64) return 'Máximo 64 caracteres';
                return null;
            },

            NombreParentezco: (v) =>
                p.some((a) => a.Nombre === v) ? null : 'Seleccione un parentezco',

            Porcentaje: (v) =>
                Number.isInteger(v) && v >= 1 && v <= 100
                    ? null
                    : 'El porcentaje debe estar entre 1 y 100',
        },
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
    },[b])
    
    const handleSubmit = async (values: typeof form.values) => {
        
        const request = {
            Id: b.Id,
            User: userSession.getUserName(),
            Porcentaje: values.Porcentaje,
            Nombre: values.Nombre,
            IdParentezco: getParentescoId(p, values.NombreParentezco)
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
        const result = await fetch("/api/deleteBeneficiary", {
            method: "DELETE",
            body: JSON.stringify({
                beneficiaryId: form.values.Id,
                user: userSession.getUserName(),
                account: accountNumber
            }),
            headers: {
                "Content-Type": "application/json",
            },
        })
        const data = await result.json()
        console.log(data)
        close()
        //navigate(0)
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

function NuevoBeneficiarioForm({p, t}: {p:any[], t:DocId[]}){
    const {accountNumber} = useParams()
    const [opened, {open, close}] = useDisclosure(false)

    const form = useForm({
        initialValues: {
            Nombre: '',
            IdBeneficiario: '',
            TipoIdentidad: '',
            Porcentaje: 0,
            NombreParentezco: '',
            FechaNacimiento: '',
            Email: '',
            Telefono: '',
            Telefono2: '',
            
        },
        validate: {
            TipoIdentidad: (v) =>
                t.some((a) => a.Nombre === v) ? null : 'Seleccione un tipo de identificación',

            IdBeneficiario: (v) => {
                const s = v.trim();
                if (!s) return 'La identificación es obligatoria';
                if (s.length > 64) return 'Máximo 64 caracteres';
                return null;
            },

            FechaNacimiento: (v) => {
                if (!v) return 'La fecha de nacimiento es obligatoria';
                const d = new Date(v);
                if (isNaN(d.getTime())) return 'Fecha inválida';
                if (d > new Date()) return 'La fecha no puede estar en el futuro';
                return null;
            },

            Nombre: (v) => {
                const s = v.trim();
                if (!s) return 'El nombre es obligatorio';
                if (s.length > 64) return 'Máximo 64 caracteres';
                return null;
            },

            NombreParentezco: (v) =>
                p.some((a) => a.Nombre === v) ? null : 'Seleccione un parentezco',

            Porcentaje: (v) =>
                Number.isInteger(v) && v >= 1 && v <= 100
                    ? null
                    : 'El porcentaje debe estar entre 1 y 100',

            Email: (v) => {
                const s = v.trim();
                if (!s) return 'El email es obligatorio';
                if (s.length > 64) return 'Máximo 64 caracteres';
                return /^\S+@\S+\.\S+$/.test(s) ? null : 'Email inválido';
            },

            Telefono: (v) => {
                const s = v.trim();
                if (!s) return 'El teléfono es obligatorio';
                return /^[0-9+\-\s()]{7,32}$/.test(s) ? null : 'Teléfono inválido';
            },

            // optional: only validated if filled in
            Telefono2: (v) => {
                const s = v.trim();
                if (!s) return null;
                return /^[0-9+\-\s()]{7,32}$/.test(s) ? null : 'Teléfono inválido';
            },
        },
    });

    const handleSubmit = async (values: typeof form.values) => {
        console.log(values)
        
        const result = await fetch("/api/addBeneficiary", {
            method: "POST",

            body: JSON.stringify({
                user: userSession.getUserName(),
                account: accountNumber,
                document: form.values.IdBeneficiario,
                documentType: getDocId(t, form.values.TipoIdentidad),
                name: form.values.Nombre,
                birthDate: form.values.FechaNacimiento,
                email: form.values.Email,
                phone: form.values.Telefono,
                phone2: form.values.Telefono2,
                relationshipId: getParentescoId(p, form.values.NombreParentezco),
                percentage: form.values.Porcentaje
            }),
            headers: {
                "Content-Type": "application/json",
            },
        })
        const data = await result.json()
        console.log(data)
        close();
        //navigate(0)
    };
    
    return(
        <>
            <Button onClick={open}>Agregar</Button>
            <Modal opened={opened} onClose={close}>
                <Form onSubmit={form.onSubmit(handleSubmit)}>
                    <Select label="Tipo de identinficación"  {...form.getInputProps("TipoIdentidad")}
                    data={t.map((a) => a.Nombre)}/>
                    <TextInput label="Identificación"  {...form.getInputProps("IdBeneficiario")}></TextInput>
                    <DateInput label="Fecha de nacimiento" {...form.getInputProps("FechaNacimiento")} />

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
                        <Button fullWidth type="submit">Agregar</Button>
                    </Group>
                </Form>
            </Modal>
        </>
    );
}

function PercentageAlert({actual}: {actual: number}) {
    return(
        <Alert variant="light" color="red" title="Error de porcentaje">
            La distribución de porcentajes de los beneficiarios suma {actual}%, modifique los porcentajes de los beneficiarios para que sea menor a 100% 
        </Alert>
    );
}

function BeneficiariesPage() {
    const navigate = useNavigate();
    const {accountNumber} = useParams()
    const [beneficiaries, setBeneficiaries] = useState<beneficiary[]>([])
    const [parentescos, setParentescos] = useState([])
    const [totalPorcentaje, setTotalPorcentaje] = useState(0)
    const [tipoDocId, setTipoDocId] = useState<DocId[]>([])

    useEffect(() => {
        fetchBeneficiaries()
            .then(async () => {await fetchParentescos()})
            .then(async () => {await fetchTipoDocId()})
            .then(async () => {await fetchTotalPorcentaje()})
    }, [])

    async function fetchTipoDocId(){
        const result = await fetch("/api/getTipoDocId")
        const data = await result.json()
        setTipoDocId(data)
        //console.log(data)
    }
    
    async function fetchBeneficiaries(){
        const result = await fetch("/api/getAccountBeneficiaries/"+accountNumber)
        const data = await result.json()
        setBeneficiaries(data)
        //console.log(data)
    }
    
    async function fetchParentescos(){
        const result = await fetch("/api/getParentescos")
        const data = await result.json()
        setParentescos(data)
    }
    
    async function fetchTotalPorcentaje(){
        const result = await fetch("/api/getPorcentaje/"+accountNumber)
        const data = await result.json()
        console.log(data[0]["Total"])
        setTotalPorcentaje(data[0]["Total"])
    }

    return (
        <Stack mt="50px" h="70vh" w="100vw" align="center" justify="center" gap="md">
            {totalPorcentaje>100 ? <PercentageAlert actual={totalPorcentaje}/> : null}
            <Stack align="stretch">
                <Button onClick={() => {navigate("/")}}>Regresar a Inicio</Button>
                <Group justify="space-between">
                    <Title>Beneficiarios</Title>
                    {beneficiaries.length < 3 ? <NuevoBeneficiarioForm p={parentescos} t={tipoDocId}/> : null}
                </Group>
                
                {beneficiaries.map(
                    (bData) => <BeneficiaryCard b={bData} p={parentescos} />
                )}
            </Stack>
        </Stack>
    );
}

export default BeneficiariesPage;