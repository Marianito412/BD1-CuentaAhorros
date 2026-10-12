class UserSessionService {
  private userName: string;
  private userId: number | null;
  private isAdmin: boolean;

  constructor() {
    this.userName = "";
    this.userId = null;
    this.isAdmin = false;
  }

  public async tryLogin(user: string, password: string): Promise<boolean> {
    try {
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

      if (!response.ok) {
        console.log("HTTP ERROR: " + response.status);
        this.clearSession();
        return false;
      }

      const body = await response.json();

      if (body.status === "success") {
        this.userName = body.user;
        this.userId = body.userId;
        this.isAdmin = body.isAdmin;
        return true;
      }

      this.clearSession();
      return false;
    } catch (error) {
      console.error("Error al iniciar sesión:", error);
      this.clearSession();
      return false;
    }
  }

  public getUserName(): string {
    return this.userName;
  }

  public getUserId(): number | null {
    return this.userId;
  }

  public getIsAdmin(): boolean {
    return this.isAdmin;
  }

  public isLoggedIn(): boolean {
    return this.userName !== "";
  }

  public clearSession(): void {
    this.userName = "";
    this.userId = null;
    this.isAdmin = false;
  }
}

const userSession = new UserSessionService();

export default userSession;
