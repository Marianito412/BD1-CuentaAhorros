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
  CantidadOperacionesATM: number;
  CantidadOperacionesHumano: number;
  CantidadOperacionesSinpe: number;
};

type Movement = {
  Id: number;
  Fecha: string;
  TipoMovimiento: string;
  flagEsCredito: boolean;
  Monto: string;
  Simbolo: string;
  Descripcion: string;
  NuevoSaldo: string;
};

const tableStyle = {
  width: "100%",
  borderCollapse: "collapse" as const,
  marginTop: "15px",
};

const cellStyle = {
  padding: "8px 10px",
  borderBottom: "1px solid #444",
  textAlign: "left" as const,
};

function StatementsPage() {
  const navigate = useNavigate();
  const { accountNumber } = useParams();

  const [statements, setStatements] = useState<Statement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [selectedStatement, setSelectedStatement] = useState<Statement | null>(
    null,
  );
  const [movements, setMovements] = useState<Movement[]>([]);
  const [loadingMovements, setLoadingMovements] = useState(false);
  const [movementsError, setMovementsError] = useState("");

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

  async function loadMovements(statement: Statement) {
    const user = userSession.getUserName();

    if (!user) {
      navigate("/login");
      return;
    }

    setSelectedStatement(statement);
    setMovements([]);
    setMovementsError("");
    setLoadingMovements(true);

    try {
      const response = await fetch(
        `/api/getStatementMovements?user=${encodeURIComponent(
          user,
        )}&statementId=${statement.Id}`,
      );

      const body = await response.json();

      if (body.status === "success") {
        setMovements(body.movements);
      } else {
        setMovementsError(
          body.message || "No fue posible cargar los movimientos.",
        );
      }
    } catch (error) {
      console.error(error);
      setMovementsError("No fue posible conectar con el servidor.");
    } finally {
      setLoadingMovements(false);
    }
  }

  function formatMoney(value: string) {
    return Number(value).toLocaleString("es-CR", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }

  // El backend envia las fechas a medianoche en hora UTC; se leen en UTC
  // para que la zona horaria de Costa Rica no las corra un dia hacia atras
  function formatDate(value: string) {
    const date = new Date(value);
    const day = String(date.getUTCDate()).padStart(2, "0");
    const month = String(date.getUTCMonth() + 1).padStart(2, "0");
    const year = date.getUTCFullYear();
    return `${day}/${month}/${year}`;
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
              <strong>Saldo mínimo:</strong>{" "}
              {formatMoney(statement.SaldoMinimo)}
            </p>

            <p>
              <strong>Saldo inicial:</strong>{" "}
              {formatMoney(statement.SaldoInicial)}
            </p>

            <p>
              <strong>Saldo final:</strong> {formatMoney(statement.SaldoFinal)}
            </p>

            <hr />

            <p>
              <strong>Operaciones en ATM:</strong>{" "}
              {statement.CantidadOperacionesATM}
            </p>

            <p>
              <strong>Operaciones en cajero humano:</strong>{" "}
              {statement.CantidadOperacionesHumano}
            </p>

            <p>
              <strong>Operaciones Sinpe:</strong>{" "}
              {statement.CantidadOperacionesSinpe}
            </p>

            <button type="button" onClick={() => loadMovements(statement)}>
              Ver movimientos
            </button>
          </div>
        ))}
      </div>

      {selectedStatement && (
        <div className="statement-card" style={{ marginTop: "30px" }}>
          <h2>
            Movimientos del {formatDate(selectedStatement.FechaInicio)} al{" "}
            {formatDate(selectedStatement.FechaFin)}
          </h2>

          {loadingMovements && <p>Cargando movimientos...</p>}

          {movementsError && <p>{movementsError}</p>}

          {!loadingMovements && !movementsError && movements.length === 0 && (
            <p>No hay movimientos en este estado de cuenta.</p>
          )}

          {movements.length > 0 && (
            <table style={tableStyle}>
              <thead>
                <tr>
                  <th style={cellStyle}>Fecha</th>
                  <th style={cellStyle}>Descripción</th>
                  <th style={cellStyle}>Monto</th>
                  <th style={cellStyle}>Nuevo saldo</th>
                </tr>
              </thead>
              <tbody>
                {movements.map((movement) => (
                  <tr key={movement.Id}>
                    <td style={cellStyle}>{formatDate(movement.Fecha)}</td>
                    <td style={cellStyle}>{movement.Descripcion}</td>
                    <td style={cellStyle}>
                      {movement.flagEsCredito ? "+" : "-"}
                      {movement.Simbolo}
                      {formatMoney(movement.Monto)}
                    </td>
                    <td style={cellStyle}>
                      {movement.Simbolo}
                      {formatMoney(movement.NuevoSaldo)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}

export default StatementsPage;
