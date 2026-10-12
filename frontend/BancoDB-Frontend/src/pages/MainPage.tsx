import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import userSession from "../core/Session";

type Account = {
  Id: number;
  NumeroCuenta: string;
  Saldo: string;
  TipoCuenta: string;
  Moneda: string;
  Simbolo: string;
};

function MainPage() {
  const navigate = useNavigate();

  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadAccounts() {
      const user = userSession.getUserName();

      if (!user) {
        navigate("/login");
        return;
      }

      try {
        const response = await fetch(
          `/api/getAccounts?user=${encodeURIComponent(user)}`,
        );

        if (!response.ok) {
          throw new Error("Error al consultar las cuentas.");
        }

        const body = await response.json();

        if (body.status === "success") {
          setAccounts(body.accounts);
        } else {
          setError(body.message || "No fue posible cargar las cuentas.");
        }
      } catch (error) {
        console.error(error);
        setError("No fue posible conectar con el servidor.");
      } finally {
        setLoading(false);
      }
    }

    loadAccounts();
  }, [navigate]);

  function handleStatements(accountNumber: string) {
    navigate(`/statements/${accountNumber}`);
  }

  function handleBeneficiaries(accountNumber: string) {
    navigate(`/beneficiaries/${accountNumber}`);
  }

  if (loading) {
    return (
      <div className="page-container">
        <h2>Cargando cuentas...</h2>
      </div>
    );
  }

  return (
    <div className="page-container">
      <h1>Mis cuentas</h1>

      <p>
        Usuario: <strong>{userSession.getUserName()}</strong>
      </p>

      {error && <p>{error}</p>}

      {!error && accounts.length === 0 && (
        <p>No hay cuentas disponibles para este usuario.</p>
      )}

      <div className="accounts-container">
        {accounts.map((account) => (
          <div className="account-card" key={account.Id}>
            <h2>{account.TipoCuenta}</h2>

            <p>
              <strong>Número de cuenta:</strong> {account.NumeroCuenta}
            </p>

            <p>
              <strong>Saldo:</strong> {account.Simbolo}
              {Number(account.Saldo).toLocaleString("es-CR", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}
            </p>

            <p>
              <strong>Moneda:</strong> {account.Moneda}
            </p>

            <button
              type="button"
              onClick={() => handleStatements(account.NumeroCuenta)}
            >
              Ver estados de cuenta
            </button>

            <button
              type="button"
              onClick={() => handleBeneficiaries(account.NumeroCuenta)}
            >
              Ver beneficiarios
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default MainPage;
