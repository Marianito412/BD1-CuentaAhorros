import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import userSession from "../core/Session";

type Statement = {
  Id: number;
  NumeroCuenta: string;
  FechaInicio: string;
  FechaFin: string;
  SaldoInicial: string;
  SaldoFinal: string;
  SaldoMinimo: string;
  InteresesAcumulados: string;
  CantidadRetiros: number;
  CantidadDepositos: number;
  CantidadSinpeEntrantes: number;
  CantidadSinpeSalientes: number;
};

function StatementsPage() {
  const navigate = useNavigate();
  const { accountNumber } = useParams();

  const [statements, setStatements] = useState<Statement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadStatements() {
      const user = userSession.getUserName();

      if (!user) {
        navigate("/login");
        return;
      }

      if (!accountNumber) {
        setError("No se indicó una cuenta.");
        setLoading(false);
        return;
      }

      try {
        const response = await fetch(
          `/api/getAccountStatements?user=${encodeURIComponent(
            user,
          )}&account=${encodeURIComponent(accountNumber)}`,
        );

        if (!response.ok) {
          throw new Error("Error al consultar los estados de cuenta.");
        }

        const body = await response.json();

        if (body.status === "success") {
          setStatements(body.statements);
          setError("");
        } else {
          setError(
            body.message || "No fue posible cargar los estados de cuenta.",
          );
        }
      } catch (error) {
        console.error(error);
        setError("No fue posible conectar con el servidor.");
      } finally {
        setLoading(false);
      }
    }

    loadStatements();
  }, [accountNumber, navigate]);

  function formatMoney(value: string) {
    return Number(value).toLocaleString("es-CR", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }

  function formatDate(value: string) {
    return new Date(value).toLocaleDateString("es-CR");
  }

  if (loading) {
    return (
      <div className="page-container">
        <h2>Cargando estados de cuenta...</h2>
      </div>
    );
  }

  return (
    <div className="page-container">
      <button type="button" onClick={() => navigate("/")}>
        Volver a cuentas
      </button>

      <h1>Estados de cuenta</h1>

      <p>
        Cuenta: <strong>{accountNumber}</strong>
      </p>

      {error && <p>{error}</p>}

      {!error && statements.length === 0 && (
        <p>No hay estados de cuenta disponibles.</p>
      )}

      <div className="statements-container">
        {statements.map((statement) => (
          <div className="statement-card" key={statement.Id}>
            <h2>
              {formatDate(statement.FechaInicio)} -{" "}
              {formatDate(statement.FechaFin)}
            </h2>

            <p>
              <strong>Saldo inicial:</strong>{" "}
              {formatMoney(statement.SaldoInicial)}
            </p>

            <p>
              <strong>Saldo final:</strong> {formatMoney(statement.SaldoFinal)}
            </p>

            <p>
              <strong>Saldo mínimo:</strong>{" "}
              {formatMoney(statement.SaldoMinimo)}
            </p>

            <p>
              <strong>Intereses acumulados:</strong>{" "}
              {formatMoney(statement.InteresesAcumulados)}
            </p>

            <hr />

            <p>
              <strong>Retiros:</strong> {statement.CantidadRetiros}
            </p>

            <p>
              <strong>Depósitos:</strong> {statement.CantidadDepositos}
            </p>

            <p>
              <strong>SINPE entrantes:</strong>{" "}
              {statement.CantidadSinpeEntrantes}
            </p>

            <p>
              <strong>SINPE salientes:</strong>{" "}
              {statement.CantidadSinpeSalientes}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default StatementsPage;
