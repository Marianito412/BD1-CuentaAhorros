class UserSessionService {
  private userName: string;
  private userId: number | null;
  private isAdmin: boolean;

  constructor() {
    this.userName = this.readStorage();
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
    const body = await response.json()
    console.log(body)

    if (body["success"]){
      this.setUserName(body["username"]);
      return true;
    }

    this.setUserName("");
    return false;
  }

  public logout(): void {
    this.setUserName("");
  }

  public getUserName(): string {
    return this.userName;
  }
  
  private setUserName(name: string): void {
    this.userName = name;
    try {
      if (name) localStorage.setItem("BankUsername", name);
      else localStorage.removeItem("BankUsername");
    } catch {
      // storage can be blocked (private mode, quota); the in-memory value still works
    }
  }

  private readStorage(): string {
    try {
      return localStorage.getItem("BankUsername") ?? "";
    } catch {
      return "";
    }
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
