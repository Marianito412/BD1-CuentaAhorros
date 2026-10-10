class UserSessionService {
  private userName: string

  constructor() {
    this.userName = ""
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
      this.userName = body["username"]
      return true;
    }

    this.userName = ""
    return false;
  }

  public getUserName(): string {
    return this.userName;
  }

}

const userSession = new UserSessionService();
export default userSession;