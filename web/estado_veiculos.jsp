<%-- 
    Document   : estado_veiculos
    Created on : 16/01/2026, 11:37:49
    Author     : pmnch
--%>

<%-- 
    Document   : estado_veiculos
    Created on : 16/01/2026, 11:37:49
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    String tipo = (String) session.getAttribute("tipo");
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Estado do Veículo - Escola de Condução</title>
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
        }
        
        .veiculos-grid {
            display: grid;
            gap: 30px;
        }
        
        .veiculo-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 193, 7, 0.2);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .veiculo-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid rgba(255, 193, 7, 0.2);
        }
        
        .veiculo-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .veiculo-icon {
            font-size: 2.5rem;
            color: #FFC107;
        }
        
        .veiculo-details h2 {
            margin: 0;
            color: white;
            font-size: 1.5rem;
        }
        
        .veiculo-details p {
            margin: 5px 0 0;
            color: rgba(255, 255, 255, 0.7);
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .status-ativo {
            background: rgba(76, 175, 80, 0.2);
            color: #4CAF50;
            border: 1px solid #4CAF50;
        }
        
        .status-inativo {
            background: rgba(244, 67, 54, 0.2);
            color: #f44336;
            border: 1px solid #f44336;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .info-item {
            background: rgba(255, 255, 255, 0.05);
            padding: 15px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .info-item label {
            display: block;
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-item .value {
            font-size: 1.1rem;
            font-weight: 600;
            color: white;
        }
        
        .validade-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .validade-ok {
            color: #4CAF50;
        }
        
        .validade-aviso {
            color: #FF9800;
        }
        
        .validade-expirado {
            color: #f44336;
        }
        
        .section-title {
            font-size: 1.2rem;
            color: #FFC107;
            margin: 25px 0 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 193, 7, 0.3);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .manutencoes-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .manutencao-item {
            background: rgba(0, 0, 0, 0.2);
            padding: 15px;
            border-radius: 10px;
            border-left: 4px solid #FFC107;
        }
        
        .manutencao-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        
        .manutencao-tipo {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .tipo-revisao { background: rgba(33, 150, 243, 0.2); color: #2196F3; }
        .tipo-batida { background: rgba(244, 67, 54, 0.2); color: #f44336; }
        .tipo-pneus { background: rgba(156, 39, 176, 0.2); color: #9C27B0; }
        .tipo-oleo { background: rgba(255, 152, 0, 0.2); color: #FF9800; }
        .tipo-travoes { background: rgba(244, 67, 54, 0.2); color: #f44336; }
        .tipo-bateria { background: rgba(76, 175, 80, 0.2); color: #4CAF50; }
        .tipo-ar { background: rgba(3, 169, 244, 0.2); color: #03A9F4; }
        .tipo-ipo { background: rgba(255, 193, 7, 0.2); color: #FFC107; }
        .tipo-outro { background: rgba(158, 158, 158, 0.2); color: #9E9E9E; }
        
        .manutencao-data {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.9rem;
        }
        
        .manutencao-custo {
            color: #FFC107;
            font-weight: 700;
            font-size: 1.1rem;
        }
        
        .manutencao-descricao {
            color: rgba(255, 255, 255, 0.8);
            margin-top: 8px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: rgba(255, 255, 255, 0.5);
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }
        
        @media (max-width: 768px) {
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .veiculo-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-shield"></i>
                <span><strong><%= username %></strong> (<%= tipo %>)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <div class="container">
        <a href="<%= tipo.equals("Admin") ? "dashboard.jsp" : "dashboard_instrutor.jsp" %>" class="logo-link">
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="page-header">
            <h1>
                <i class="fa fa-car"></i>
                <%= tipo.equals("Instrutor") ? "Estado do Meu Veículo" : "Estado dos Veículos" %>
            </h1>
            <a href="<%= tipo.equals("Admin") ? "dashboard.jsp" : "dashboard_instrutor.jsp" %>" class="btn">
                <i class="fa fa-arrow-left"></i>
                Voltar
            </a>
        </div>

        <div class="veiculos-grid">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = ConexaoBD.getConnection();
                    
                    String sql;
                    
                    // Se for INSTRUTOR, mostra SÓ o seu veículo
                    if ("Instrutor".equals(tipo)) {
                        sql = "SELECT v.*, i.nome as nomeInstrutor " +
                             "FROM veiculo v " +
                             "JOIN instrutor i ON i.idVeiculo = v.id " +
                             "WHERE i.email = (SELECT email FROM t_utilizador WHERE username = ?)";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, username);
                    } else {
                        // Se for ADMIN, mostra TODOS os veículos
                        sql = "SELECT v.*, i.nome as nomeInstrutor " +
                             "FROM veiculo v " +
                             "LEFT JOIN instrutor i ON i.idVeiculo = v.id " +
                             "ORDER BY v.ativo DESC, v.marca, v.modelo";
                        pstmt = conn.prepareStatement(sql);
                    }
                    
                    rs = pstmt.executeQuery();
                    
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                    java.util.Date hoje = new java.util.Date();
                    Calendar cal30 = Calendar.getInstance();
                    cal30.add(Calendar.DAY_OF_MONTH, 30);
                    java.util.Date daqui30 = cal30.getTime();
                    
                    while (rs.next()) {
                        int idVeiculo = rs.getInt("id");
                        String marca = rs.getString("marca");
                        String modelo = rs.getString("modelo");
                        String matricula = rs.getString("matricula");
                        boolean ativo = rs.getBoolean("ativo");
                        String nomeInstrutor = rs.getString("nomeInstrutor");
                        
                        java.util.Date dataSeguro = rs.getDate("dataSeguro");
                        java.util.Date dataIUC = rs.getDate("dataIUC");
                        java.util.Date dataRevisao = rs.getDate("dataRevisao");
                        java.util.Date dataIPO = rs.getDate("dataIPO");
                        int km = rs.getInt("km");
                        String observacoes = rs.getString("observacoes");
            %>
                        <div class="veiculo-card">
                            <div class="veiculo-header">
                                <div class="veiculo-info">
                                    <i class="fa fa-car veiculo-icon"></i>
                                    <div class="veiculo-details">
                                        <h2><%= marca %> <%= modelo %></h2>
                                        <p><strong>Matrícula:</strong> <%= matricula %></p>
                                        <% if (nomeInstrutor != null) { %>
                                            <p><strong>Instrutor:</strong> <%= nomeInstrutor %></p>
                                        <% } %>
                                    </div>
                                </div>
                                <span class="status-badge <%= ativo ? "status-ativo" : "status-inativo" %>">
                                    <%= ativo ? "Ativo" : "Inativo" %>
                                </span>
                            </div>
                            
                            <div class="info-grid">
                                <div class="info-item">
                                    <label>Quilometragem</label>
                                    <div class="value"><%= String.format("%,d", km) %> km</div>
                                </div>
                                
                                <div class="info-item validade-item">
                                    <div>
                                        <label>Seguro</label>
                                        <div class="value">
                                            <% if (dataSeguro != null) {
                                                String classeValidade = "validade-ok";
                                                if (dataSeguro.before(hoje)) classeValidade = "validade-expirado";
                                                else if (dataSeguro.before(daqui30)) classeValidade = "validade-aviso";
                                            %>
                                                <span class="<%= classeValidade %>"><%= sdf.format(dataSeguro) %></span>
                                            <% } else { %>
                                                <span>-</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <i class="fa fa-shield-alt" style="color: #FFC107;"></i>
                                </div>
                                
                                <div class="info-item validade-item">
                                    <div>
                                        <label>IUC</label>
                                        <div class="value">
                                            <% if (dataIUC != null) {
                                                String classeValidade = "validade-ok";
                                                if (dataIUC.before(hoje)) classeValidade = "validade-expirado";
                                                else if (dataIUC.before(daqui30)) classeValidade = "validade-aviso";
                                            %>
                                                <span class="<%= classeValidade %>"><%= sdf.format(dataIUC) %></span>
                                            <% } else { %>
                                                <span>-</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <i class="fa fa-file-invoice-dollar" style="color: #FFC107;"></i>
                                </div>
                                
                                <div class="info-item validade-item">
                                    <div>
                                        <label>Revisão</label>
                                        <div class="value">
                                            <% if (dataRevisao != null) {
                                                String classeValidade = "validade-ok";
                                                if (dataRevisao.before(hoje)) classeValidade = "validade-expirado";
                                                else if (dataRevisao.before(daqui30)) classeValidade = "validade-aviso";
                                            %>
                                                <span class="<%= classeValidade %>"><%= sdf.format(dataRevisao) %></span>
                                            <% } else { %>
                                                <span>-</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <i class="fa fa-tools" style="color: #FFC107;"></i>
                                </div>
                                
                                <div class="info-item validade-item">
                                    <div>
                                        <label>IPO/Inspeção</label>
                                        <div class="value">
                                            <% if (dataIPO != null) {
                                                String classeValidade = "validade-ok";
                                                if (dataIPO.before(hoje)) classeValidade = "validade-expirado";
                                                else if (dataIPO.before(daqui30)) classeValidade = "validade-aviso";
                                            %>
                                                <span class="<%= classeValidade %>"><%= sdf.format(dataIPO) %></span>
                                            <% } else { %>
                                                <span>-</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <i class="fa fa-clipboard-check" style="color: #FFC107;"></i>
                                </div>
                            </div>
                            
                            <% if (observacoes != null && !observacoes.isEmpty()) { %>
                                <div class="info-item" style="margin-top: 15px;">
                                    <label>Observações</label>
                                    <div class="value"><%= observacoes %></div>
                                </div>
                            <% } %>
                            
                            <div class="section-title">
                                <i class="fa fa-wrench"></i>
                                Histórico de Manutenções
                            </div>
                            
                            <div class="manutencoes-list">
                                <%
                                    PreparedStatement pstmtMan = conn.prepareStatement(
                                        "SELECT * FROM manutencao WHERE idVeiculo = ? ORDER BY data DESC LIMIT 10"
                                    );
                                    pstmtMan.setInt(1, idVeiculo);
                                    ResultSet rsMan = pstmtMan.executeQuery();
                                    
                                    boolean temManutencoes = false;
                                    while (rsMan.next()) {
                                        temManutencoes = true;
                                        String tipoMan = rsMan.getString("tipo");
                                        if (tipoMan == null) tipoMan = "Outro";
                                        
                                        String classeTipo = "tipo-outro";
                                        String iconeTipo = "fa-wrench";
                                        
                                        switch(tipoMan.toLowerCase()) {
                                            case "revisão":
                                            case "revisao":
                                                classeTipo = "tipo-revisao";
                                                iconeTipo = "fa-tools";
                                                break;
                                            case "batida":
                                                classeTipo = "tipo-batida";
                                                iconeTipo = "fa-car-crash";
                                                break;
                                            case "pneus":
                                                classeTipo = "tipo-pneus";
                                                iconeTipo = "fa-circle";
                                                break;
                                            case "óleo":
                                            case "oleo":
                                                classeTipo = "tipo-oleo";
                                                iconeTipo = "fa-oil-can";
                                                break;
                                            case "travões":
                                            case "travoes":
                                                classeTipo = "tipo-travoes";
                                                iconeTipo = "fa-stop-circle";
                                                break;
                                            case "bateria":
                                                classeTipo = "tipo-bateria";
                                                iconeTipo = "fa-car-battery";
                                                break;
                                            case "ar condicionado":
                                                classeTipo = "tipo-ar";
                                                iconeTipo = "fa-snowflake";
                                                break;
                                            case "ipo":
                                                classeTipo = "tipo-ipo";
                                                iconeTipo = "fa-clipboard-check";
                                                break;
                                        }
                                %>
                                        <div class="manutencao-item">
                                            <div class="manutencao-header">
                                                <span class="manutencao-tipo <%= classeTipo %>">
                                                    <i class="fa <%= iconeTipo %>"></i>
                                                    <%= tipoMan %>
                                                </span>
                                                <span class="manutencao-data">
                                                    <%= sdf.format(rsMan.getDate("data")) %>
                                                </span>
                                                <span class="manutencao-custo">
                                                    <%= String.format("€%.2f", rsMan.getDouble("custo")) %>
                                                </span>
                                            </div>
                                            <div class="manutencao-descricao">
                                                <%= rsMan.getString("descricao") %>
                                            </div>
                                        </div>
                                <%
                                    }
                                    
                                    if (!temManutencoes) {
                                %>
                                        <div class="empty-state">
                                            <i class="fa fa-wrench"></i>
                                            <p>Sem manutenções registadas</p>
                                        </div>
                                <%
                                    }
                                    
                                    rsMan.close();
                                    pstmtMan.close();
                                %>
                            </div>
                        </div>
            <%
                    }
                    
                } catch (Exception e) {
                    out.println("<p>Erro: " + e.getMessage() + "</p>");
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
    </div>
</body>
</html>
