<%-- 
    Document   : perfil_aluno
    Created on : 13/01/2026, 11:53:12
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // VALIDAÇÃO DE SESSÃO
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Aluno".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");

    // DEBUG - MOSTRAR VALORES
    Integer idUtilizador = (Integer) session.getAttribute("idUtilizador");
    String debugInfo = "";
    debugInfo += "Username: " + username + "<br>";
    debugInfo += "ID Utilizador: " + idUtilizador + "<br>";

    // BUSCAR EMAIL DO UTILIZADOR
    Connection connUser = null;
    PreparedStatement pstmtUser = null;
    ResultSet rsUser = null;
    
    String emailUtilizador = "";
    Integer idAluno = null;
    
    try {
        connUser = ConexaoBD.getConnection();
        String sqlUser = "SELECT email FROM t_utilizador WHERE id = ?";
        pstmtUser = connUser.prepareStatement(sqlUser);
        pstmtUser.setInt(1, idUtilizador);
        rsUser = pstmtUser.executeQuery();
        
        if (rsUser.next()) {
            emailUtilizador = rsUser.getString("email");
            debugInfo += "Email Utilizador: " + emailUtilizador + "<br>";
        } else {
            debugInfo += "❌ Utilizador não encontrado!<br>";
        }
        rsUser.close();
        pstmtUser.close();
        
        // BUSCAR ALUNO PELO EMAIL
        if (!emailUtilizador.isEmpty()) {
            String sqlAluno = "SELECT id FROM aluno WHERE email = ?";
            pstmtUser = connUser.prepareStatement(sqlAluno);
            pstmtUser.setString(1, emailUtilizador);
            rsUser = pstmtUser.executeQuery();
            
            if (rsUser.next()) {
                idAluno = rsUser.getInt("id");
                debugInfo += "✅ ID Aluno encontrado: " + idAluno + "<br>";
            } else {
                debugInfo += "❌ Aluno não encontrado com email: " + emailUtilizador + "<br>";
            }
        }
        
    } catch (Exception e) {
        debugInfo += "❌ ERRO: " + e.getMessage() + "<br>";
        e.printStackTrace();
    } finally {
        try {
            if (rsUser != null) rsUser.close();
            if (pstmtUser != null) pstmtUser.close();
            if (connUser != null) connUser.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // CARREGAR DADOS DO ALUNO
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String nome = "";
    String email = "";
    String telemovel = "";
    String morada = "";
    String dataNascimento = "";
    String categoria = "";
    String dataInscricao = "";
    
    if (idAluno != null) {
        try {
            conn = ConexaoBD.getConnection();
            String sql = "SELECT * FROM aluno WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idAluno);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                nome = rs.getString("nome");
                email = rs.getString("email");
                telemovel = rs.getString("telemovel");
                morada = rs.getString("morada");
                dataNascimento = rs.getDate("dataNascimento").toString();
                categoria = rs.getString("categoria");
                dataInscricao = rs.getDate("dataInscricao").toString();
                debugInfo += "✅ Dados do aluno carregados!<br>";
            }
        } catch (Exception e) {
            debugInfo += "❌ ERRO ao carregar dados: " + e.getMessage() + "<br>";
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Meu Perfil - Escola de Condução</title>
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
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
        }
        
        .topbar {
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(10px);
            padding: 15px 0;
            border-bottom: 1px solid rgba(255, 193, 7, 0.2);
        }
        
        .topbar .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .topbar .user-info {
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .topbar .user-info i {
            color: #FFC107;
        }
        
        .btn-sair {
            background: rgba(128, 0, 32, 0.8);
            color: white;
            padding: 10px 25px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .btn-sair:hover {
            background: #800020;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(128, 0, 32, 0.5);
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        
        .logo-link {
            display: block;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo-link img {
            height: 60px;
            width: auto;
            filter: drop-shadow(0 0 10px rgba(255, 193, 7, 0.3));
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 193, 7, 0.2);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .page-header i {
            font-size: 4rem;
            color: #FFC107;
            margin-bottom: 15px;
        }
        
        .page-header h1 {
            color: white;
            font-size: 2rem;
            margin-bottom: 10px;
        }
        
        .page-header p {
            color: rgba(255, 255, 255, 0.7);
        }
        
        .debug-box {
            background: rgba(255, 152, 0, 0.2);
            border: 2px solid #FF9800;
            color: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            font-family: monospace;
            font-size: 0.9rem;
            line-height: 1.8;
        }
        
        .debug-box h3 {
            color: #FFC107;
            margin-bottom: 15px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .info-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 20px;
        }
        
        .info-item label {
            display: block;
            color: #FFC107;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        
        .info-item .value {
            color: white;
            font-size: 1.1rem;
        }
        
        .categoria-badge {
            display: inline-block;
            background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%);
            color: #1a3a4d;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 1.2rem;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: #FFC107;
        }
        
        .alert-warning {
            background: rgba(255, 152, 0, 0.2);
            border: 2px solid #FF9800;
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <!-- TOPBAR -->
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-graduate"></i>
                <span><strong><%= username %></strong> (Aluno)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <!-- CONTAINER -->
    <div class="container">
        <!-- LOGO -->
        <a href="dashboard_aluno.jsp" class="logo-link">
            <img src="image/logo.png" alt="Drive School">
        </a>

        <div class="content-card">
            <div class="page-header">
                <i class="fa fa-user-circle"></i>
                <h1>Meu Perfil</h1>
                <p>Informações pessoais e dados do curso</p>
            </div>

            <!-- DEBUG INFO -->
            <div class="debug-box">
                <h3><i class="fa fa-bug"></i> Informação de Debug:</h3>
                <%= debugInfo %>
            </div>

            <% if (idAluno == null || nome.isEmpty()) { %>
                <div class="alert-warning">
                    <i class="fa fa-exclamation-triangle" style="font-size: 2rem; margin-bottom: 10px;"></i>
                    <h3>Perfil não encontrado</h3>
                    <p>Verifica a informação de debug acima para perceber o problema.</p>
                </div>
            <% } else { %>
                <div class="info-grid">
                    <div class="info-item">
                        <label><i class="fa fa-user"></i> Nome Completo</label>
                        <div class="value"><%= nome %></div>
                    </div>

                    <div class="info-item">
                        <label><i class="fa fa-envelope"></i> Email</label>
                        <div class="value"><%= email %></div>
                    </div>

                    <div class="info-item">
                        <label><i class="fa fa-phone"></i> Telemóvel</label>
                        <div class="value"><%= telemovel %></div>
                    </div>

                    <div class="info-item">
                        <label><i class="fa fa-birthday-cake"></i> Data de Nascimento</label>
                        <div class="value"><%= dataNascimento %></div>
                    </div>

                    <div class="info-item" style="grid-column: 1 / -1;">
                        <label><i class="fa fa-home"></i> Morada</label>
                        <div class="value"><%= morada %></div>
                    </div>

                    <div class="info-item">
                        <label><i class="fa fa-id-card"></i> Categoria</label>
                        <div class="value">
                            <span class="categoria-badge">Categoria <%= categoria %></span>
                        </div>
                    </div>

                    <div class="info-item">
                        <label><i class="fa fa-calendar"></i> Data de Inscrição</label>
                        <div class="value"><%= dataInscricao %></div>
                    </div>
                </div>
            <% } %>

            <div class="btn-group">
                <a href="dashboard_aluno.jsp" class="btn btn-secondary">
                    <i class="fa fa-arrow-left"></i>
                    Voltar ao Dashboard
                </a>
            </div>
        </div>
    </div>
</body>
</html>

