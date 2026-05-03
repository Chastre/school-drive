<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
    Author     : pmnch
--%>

<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
    Author     : pmnch
--%>

<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
    Author     : pmnch
--%>

<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
    Author     : pmnch
--%>

<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
    Author     : pmnch
--%>

<%-- 
    Document   : meus_pagamentos
    Created on : 13/01/2026, 11:54:29
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

    // BUSCAR ID DO ALUNO USANDO USERNAME
    Integer idAluno = null;
    String nomeAluno = "";
    String emailAluno = "";

    Connection connAluno = null;
    PreparedStatement pstmtAluno = null;
    ResultSet rsAluno = null;

    try {
        connAluno = ConexaoBD.getConnection();
        
        // Buscar idAluno diretamente da tabela t_utilizador
        String sqlAluno = "SELECT u.idAluno, a.nome, a.email FROM t_utilizador u LEFT JOIN aluno a ON u.idAluno = a.id WHERE u.username = ?";
        pstmtAluno = connAluno.prepareStatement(sqlAluno);
        pstmtAluno.setString(1, username);
        rsAluno = pstmtAluno.executeQuery();
        
        if (rsAluno.next()) {
            int idAlunoTemp = rsAluno.getInt("idAluno");
            if (!rsAluno.wasNull() && idAlunoTemp > 0) {
                idAluno = idAlunoTemp;
            }
            nomeAluno = rsAluno.getString("nome") != null ? rsAluno.getString("nome") : username;
            emailAluno = rsAluno.getString("email") != null ? rsAluno.getString("email") : "";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rsAluno != null) rsAluno.close();
            if (pstmtAluno != null) pstmtAluno.close();
            if (connAluno != null) connAluno.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Meus Pagamentos - Escola de Condução</title>
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
            max-width: 1400px;
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
            max-width: 1400px;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .page-header h1 {
            color: white;
            font-size: 2rem;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-header h1 i {
            color: #FFC107;
        }
        
        .btn {
            padding: 12px 25px;
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
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: #FFC107;
            transform: translateY(-2px);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 193, 7, 0.3);
            border-radius: 20px;
            padding: 30px;
            text-align: center;
            transition: all 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 10px 30px rgba(255, 193, 7, 0.2);
        }
        
        .stat-card i {
            font-size: 3rem;
            color: #FFC107;
            margin-bottom: 15px;
        }
        
        .stat-card .label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 1rem;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .stat-card .value {
            color: white;
            font-size: 2.5rem;
            font-weight: 700;
        }
        
        .section-title {
            color: white;
            font-size: 1.5rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title i {
            color: #FFC107;
        }
        
        .table-container {
            overflow-x: auto;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 15px;
            padding: 20px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
        }
        
        th {
            padding: 18px 15px;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        tbody tr {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background: transparent;
            transition: all 0.3s;
        }
        
        tbody tr:hover {
            background: rgba(255, 193, 7, 0.15);
        }
        
        td {
            padding: 20px 15px;
            color: rgba(255, 255, 255, 0.9);
            font-size: 1rem;
        }
        
        .valor-destaque {
            color: #FFC107;
            font-weight: 700;
            font-size: 1.3rem;
        }
        
        .metodo-badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            background: rgba(255, 193, 7, 0.2);
            color: #FFC107;
            border: 2px solid #FFC107;
        }
        
        .data-destaque {
            font-weight: 600;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: rgba(255, 255, 255, 0.7);
        }
        
        .empty-state i {
            font-size: 5rem;
            color: rgba(255, 193, 7, 0.3);
            margin-bottom: 25px;
        }
        
        .empty-state h3 {
            font-size: 1.5rem;
            margin-bottom: 10px;
            color: white;
        }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .topbar .container {
                flex-direction: column;
                gap: 10px;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            table {
                font-size: 0.85rem;
            }
            
            th, td {
                padding: 12px 8px;
            }
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
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="content-card">
            <div class="page-header">
                <h1>
                    <i class="fa fa-money-bill-wave"></i>
                    Meus Pagamentos
                </h1>
                <a href="dashboard_aluno.jsp" class="btn">
                    <i class="fa fa-arrow-left"></i>
                    Voltar
                </a>
            </div>

            <%
            if (idAluno == null) {
            %>
                <div class="empty-state">
                    <i class="fa fa-exclamation-triangle"></i>
                    <h3>Erro ao carregar dados</h3>
                    <p>Não foi possível identificar o aluno. Contacta a administração.</p>
                    <p style="font-size: 0.9rem; margin-top: 20px;">Username: <%= username %></p>
                </div>
            <%
            } else {
                // CALCULAR ESTATÍSTICAS
                Connection connStats = null;
                PreparedStatement pstmtStats = null;
                ResultSet rsStats = null;
                
                double totalPago = 0;
                int numPagamentos = 0;
                
                try {
                    connStats = ConexaoBD.getConnection();
                    String sqlStats = "SELECT COUNT(*) as total, COALESCE(SUM(valor), 0) as soma FROM pagamento WHERE idAluno = ?";
                    pstmtStats = connStats.prepareStatement(sqlStats);
                    pstmtStats.setInt(1, idAluno);
                    rsStats = pstmtStats.executeQuery();
                    
                    if (rsStats.next()) {
                        numPagamentos = rsStats.getInt("total");
                        totalPago = rsStats.getDouble("soma");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rsStats != null) rsStats.close();
                        if (pstmtStats != null) pstmtStats.close();
                        if (connStats != null) connStats.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>

            <!-- ESTATÍSTICAS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <i class="fa fa-euro-sign"></i>
                    <div class="label">Total Pago</div>
                    <div class="value"><%= String.format("%.2f", totalPago) %>€</div>
                </div>

                <div class="stat-card">
                    <i class="fa fa-receipt"></i>
                    <div class="label">Nº Pagamentos</div>
                    <div class="value"><%= numPagamentos %></div>
                </div>
            </div>

            <!-- TABELA -->
            <h2 class="section-title">
                <i class="fa fa-list"></i>
                Histórico de Pagamentos
            </h2>

            <div class="table-container">
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = ConexaoBD.getConnection();
                    String sql = "SELECT * FROM pagamento WHERE idAluno = ? ORDER BY dataPagamento DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, idAluno);
                    rs = pstmt.executeQuery();
                    
                    if (!rs.isBeforeFirst()) {
                %>
                        <div class="empty-state">
                            <i class="fa fa-money-bill-wave"></i>
                            <h3>Nenhum pagamento registado</h3>
                            <p>Quando efetuares pagamentos, eles aparecerão aqui</p>
                        </div>
                <%
                    } else {
                %>
                        <table>
                            <thead>
                                <tr>
                                    <th><i class="fa fa-calendar"></i> Data</th>
                                    <th><i class="fa fa-euro-sign"></i> Valor</th>
                                    <th><i class="fa fa-credit-card"></i> Método</th>
                                    <th><i class="fa fa-file-alt"></i> Descrição</th>
                                </tr>
                            </thead>
                            <tbody>
                <%
                        while (rs.next()) {
                            Date dataPagamento = rs.getDate("dataPagamento");
                            double valor = rs.getDouble("valor");
                            String metodoPagamento = rs.getString("metodo");
                            String descricao = rs.getString("descricao");
                %>
                            <tr>
                                <td class="data-destaque"><%= dataPagamento %></td>
                                <td><span class="valor-destaque"><%= String.format("%.2f", valor) %>€</span></td>
                                <td>
                                    <span class="metodo-badge">
                                        <%= metodoPagamento %>
                                    </span>
                                </td>
                                <td><%= descricao != null && !descricao.isEmpty() ? descricao : "-" %></td>
                            </tr>
                <%
                        }
                %>
                            </tbody>
                        </table>
                <%
                    }
                    
                } catch (Exception e) {
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
                %>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>



  







  



