<%-- 
    Document   : login
    Created on : 18/12/2025, 00:14:51
    Author     : pmnch
--%>

<%-- 
    Document   : login
    Created on : 18/12/2025, 00:14:51
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String mensagemErro = null;
    
    if (request.getMethod().equals("POST")) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // DEBUG - REMOVER DEPOIS!
        
        if (username != null && !username.trim().isEmpty() && password != null && !password.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = ConexaoBD.getConnection();
                
                String sql = "SELECT * FROM t_utilizador WHERE username = ? AND password = ? AND ativo = 1";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, username.trim());
                pstmt.setString(2, password.trim());
                
                
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    
                    int idUtilizador = rs.getInt("idUtilizador");
                    String tipo = rs.getString("tipo");
                    String user = rs.getString("username");
                    
                    
                    session.setAttribute("idUtilizador", idUtilizador);
                    session.setAttribute("username", user);
                    session.setAttribute("tipo", tipo);
                    session.setAttribute("logado", true);
                    
                    if ("Admin".equals(tipo)) {
                        response.sendRedirect("dashboard.jsp");
                    } else if ("Instrutor".equals(tipo)) {
                        response.sendRedirect("dashboard_instrutor.jsp");
                    } else if ("Aluno".equals(tipo)) {
                        response.sendRedirect("dashboard_aluno.jsp");
                    } else if ("Professor".equals(tipo)) {
                        response.sendRedirect("dashboard_professor.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                    return;
                    
                } else {
                    mensagemErro = "Utilizador ou senha incorretos.";
                }
                
            } catch (Exception e) {
                e.printStackTrace();
                mensagemErro = "Erro ao conectar à base de dados: " + e.getMessage();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            
        } else {
            mensagemErro = "Por favor, preencha todos os campos.";
        }
    }
    
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Login - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Work Sans', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #2C5F7C 0%, #800020 100%);
            padding: 20px;
        }
        
        .login-container {
            width: 100%;
            max-width: 450px;
        }
        
        .login-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 3rem;
            animation: slideUp 0.5s ease;
        }
        
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }
        
        .login-header i {
            font-size: 4.5rem;
            color: #FFC107;
            margin-bottom: 1rem;
            animation: bounce 2s infinite;
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        
        .login-header h2 {
            color: #2C5F7C;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .login-header p {
            color: #666;
            font-size: 0.95rem;
        }
        
        
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-label {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #333;
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }
        
        .form-label i {
            color: #FFC107;
        }
        
        .form-control {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid #ddd;
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s;
            font-family: 'Work Sans', sans-serif;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #FFC107;
            box-shadow: 0 0 0 4px rgba(255, 193, 7, 0.1);
        }
        
        .btn-login {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%);
            color: #333;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 2rem;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 193, 7, 0.4);
            background: linear-gradient(135deg, #FFB300 0%, #FFA000 100%);
        }
        
        .btn-login:active {
            transform: translateY(0);
        }
        
        .back-link {
            text-align: center;
            margin-top: 1.5rem;
        }
        
        .back-link a {
            color: #666;
            text-decoration: none;
            font-size: 0.95rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .back-link a:hover {
            color: #2C5F7C;
            gap: 12px;
        }
        
        .alert {
            background: #fee;
            border: 2px solid #800020;
            color: #800020;
            padding: 1rem 1.2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.95rem;
            animation: shake 0.5s;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        .alert i {
            font-size: 1.2rem;
        }
        
        .bg-decoration {
            position: fixed;
            opacity: 0.1;
            pointer-events: none;
        }
        
        .bg-decoration.circle-1 {
            width: 300px;
            height: 300px;
            background: white;
            border-radius: 50%;
            top: -100px;
            right: -100px;
        }
        
        .bg-decoration.circle-2 {
            width: 200px;
            height: 200px;
            background: white;
            border-radius: 50%;
            bottom: -50px;
            left: -50px;
        }
        
        @media (max-width: 480px) {
            .login-card {
                padding: 2rem 1.5rem;
            }
            
            .login-header h2 {
                font-size: 1.6rem;
            }
            
            .login-header i {
                font-size: 3.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="bg-decoration circle-1"></div>
    <div class="bg-decoration circle-2"></div>
    
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <i class="fa fa-car"></i>
                <h2>Escola de Condução</h2>
                <p>Faça login para aceder ao sistema</p>
            </div>
            
            <% if (mensagemErro != null) { %>
                <div class="alert">
                    <i class="fa fa-exclamation-circle"></i>
                    <span><%= mensagemErro %></span>
                </div>
            <% } %>
            
            
            
            <form method="POST" action="login.jsp">
                <div class="form-group">
                    <label class="form-label">
                        <i class="fa fa-user"></i>
                        Utilizador
                    </label>
                    <input type="text" 
                           class="form-control" 
                           name="username" 
                           placeholder="Digite seu utilizador"
                           required 
                           autofocus>
                </div>
                
                <div class="form-group">
                    <label class="form-label">
                        <i class="fa fa-lock"></i>
                        Senha
                    </label>
                    <input type="password" 
                           class="form-control" 
                           name="password" 
                           placeholder="Digite sua senha"
                           required>
                </div>
                
                <button type="submit" class="btn-login">
                    <i class="fa fa-sign-in-alt"></i>
                    Entrar no Sistema
                </button>
            </form>
            
            <div class="back-link">
                <a href="index.jsp">
                    <i class="fa fa-arrow-left"></i>
                    Voltar à página inicial
                </a>
            </div>
        </div>
    </div>
</body>
</html>

