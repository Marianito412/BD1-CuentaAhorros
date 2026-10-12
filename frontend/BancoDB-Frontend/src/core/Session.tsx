class UserSessionService {
  private userName: string

  constructor() {
    this.userName = this.readStorage();
  }

  public async tryLogin(user: string, password: string): Promise<boolean> {
    //http://127.0.0.1:5000/api/login
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

      this.userName = ""
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

  public isLoggedIn(): boolean {
    return this.userName !== "";
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

}

const userSession = new UserSessionService();
export default userSession;