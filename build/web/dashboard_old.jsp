<%-- 
    Document   : dashboard
    Created on : 18/12/2025, 00:11:41
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Buscar estatísticas
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    int totalAlunos = 0;
    int totalInstrutores = 0;
    int totalVeiculos = 0;
    int totalAulas = 0;
    int aulasAgendadas = 0;
    int aulasRealizadas = 0;
    int aulasCanceladas = 0;
    double totalRecebido = 0;
    
    try {
        conn = ConexaoBD.getConnection();
        stmt = conn.createStatement();
        
        // Total de Alunos
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM aluno");
        if (rs.next()) totalAlunos = rs.getInt("total");
        
        // Total de Instrutores
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM instrutor WHERE ativo = TRUE");
        if (rs.next()) totalInstrutores = rs.getInt("total");
        
        // Total de Veículos
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM veiculo");
        if (rs.next()) totalVeiculos = rs.getInt("total");
        
        // Total de Aulas
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM aula_conducao");
        if (rs.next()) totalAulas = rs.getInt("total");
        
        // Aulas por estado
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM aula_conducao WHERE estado = 'Agendada'");
        if (rs.next()) aulasAgendadas = rs.getInt("total");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM aula_conducao WHERE estado = 'Realizada'");
        if (rs.next()) aulasRealizadas = rs.getInt("total");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as total FROM aula_conducao WHERE estado = 'Cancelada'");
        if (rs.next()) aulasCanceladas = rs.getInt("total");
        
        // Total Recebido
        rs = stmt.executeQuery("SELECT SUM(valor) as total FROM pagamento");
        if (rs.next()) totalRecebido = rs.getDouble("total");
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Estatísticas</title>
    <link href="css/custom-colors.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
        }

        .header {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        h1 {
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            background: #6c757d;
            color: white;
        }

        .btn:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            text-align: center;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 50px rgba(0,0,0,0.3);
        }

        .stat-icon {
            font-size: 3rem;
            margin-bottom: 15px;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }

        .stat-label {
            font-size: 1rem;
            color: #666;
            font-weight: 600;
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }

        .chart-title {
            font-size: 1.3rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .chart-bar {
            margin-bottom: 15px;
        }

        .chart-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-weight: 600;
            color: #555;
        }

        .progress-bar {
            height: 30px;
            background: #e9ecef;
            border-radius: 15px;
            overflow: hidden;
            position: relative;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            transition: width 1s ease;
        }

        .progress-fill.success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .progress-fill.warning {
            background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
        }

        .progress-fill.danger {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
        }

        .recent-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .recent-item {
            padding: 15px;
            border-left: 4px solid #667eea;
            background: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .recent-item strong {
            color: #667eea;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Dashboard & Estatísticas</h1>
            <a href="index.jsp" class="btn">🏠 Voltar ao Menu</a>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">👥</div>
                <div class="stat-number"><%= totalAlunos %></div>
                <div class="stat-label">Total de Alunos</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">👨‍🏫</div>
                <div class="stat-number"><%= totalInstrutores %></div>
                <div class="stat-label">Instrutores Ativos</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">🚙</div>
                <div class="stat-number"><%= totalVeiculos %></div>
                <div class="stat-label">Total de Veículos</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">📅</div>
                <div class="stat-number"><%= totalAulas %></div>
                <div class="stat-label">Total de Aulas</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">💰</div>
                <div class="stat-number"><%= String.format("%.2f €", totalRecebido) %></div>
                <div class="stat-label">Total Recebido</div>
            </div>
        </div>

        <div class="charts-grid">
            <div class="chart-card">
                <h3 class="chart-title">📊 Aulas por Estado</h3>
                
                <div class="chart-bar">
                    <div class="chart-label">
                        <span>Agendadas</span>
                        <span><%= aulasAgendadas %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= totalAulas > 0 ? (aulasAgendadas * 100.0 / totalAulas) : 0 %>%">
                            <%= totalAulas > 0 ? String.format("%.0f%%", aulasAgendadas * 100.0 / totalAulas) : "0%" %>
                        </div>
                    </div>
                </div>

                <div class="chart-bar">
                    <div class="chart-label">
                        <span>Realizadas</span>
                        <span><%= aulasRealizadas %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill success" style="width: <%= totalAulas > 0 ? (aulasRealizadas * 100.0 / totalAulas) : 0 %>%">
                            <%= totalAulas > 0 ? String.format("%.0f%%", aulasRealizadas * 100.0 / totalAulas) : "0%" %>
                        </div>
                    </div>
                </div>

                <div class="chart-bar">
                    <div class="chart-label">
                        <span>Canceladas</span>
                        <span><%= aulasCanceladas %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill danger" style="width: <%= totalAulas > 0 ? (aulasCanceladas * 100.0 / totalAulas) : 0 %>%">
                            <%= totalAulas > 0 ? String.format("%.0f%%", aulasCanceladas * 100.0 / totalAulas) : "0%" %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="chart-card">
                <h3 class="chart-title">🎓 Alunos por Categoria</h3>
                <%
                    try {
                        conn = ConexaoBD.getConnection();
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT categoria, COUNT(*) as total FROM aluno GROUP BY categoria ORDER BY total DESC");
                        
                        boolean temDados = false;
                        while (rs.next()) {
                            temDados = true;
                            String categoria = rs.getString("categoria");
                            int total = rs.getInt("total");
                            double percentagem = totalAlunos > 0 ? (total * 100.0 / totalAlunos) : 0;
                %>
                            <div class="chart-bar">
                                <div class="chart-label">
                                    <span>Categoria <%= categoria %></span>
                                    <span><%= total %></span>
                                </div>
                                <div class="progress-bar">
                                    <div class="progress-fill warning" style="width: <%= percentagem %>%">
                                        <%= String.format("%.0f%%", percentagem) %>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                        if (!temDados) {
                %>
                            <div class="no-data">Sem dados disponíveis</div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try {
                            if (rs != null) rs.close();
                            if (stmt != null) stmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </div>
        </div>

        <div class="recent-section">
            <h3 class="section-title">📅 Próximas Aulas</h3>
            <%
                try {
                    conn = ConexaoBD.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(
                        "SELECT ac.*, a.nome as nomeAluno, i.nome as nomeInstrutor " +
                        "FROM aula_conducao ac " +
                        "LEFT JOIN aluno a ON ac.idAluno = a.id " +
                        "LEFT JOIN instrutor i ON ac.idInstrutor = i.id " +
                        "WHERE ac.estado = 'Agendada' AND ac.dataHoraInicio >= NOW() " +
                        "ORDER BY ac.dataHoraInicio ASC LIMIT 5"
                    );
                    
                    boolean temAulas = false;
                    while (rs.next()) {
                        temAulas = true;
            %>
                        <div class="recent-item">
                            <strong><%= rs.getString("nomeAluno") %></strong> com 
                            <strong><%= rs.getString("nomeInstrutor") %></strong> - 
                            <%= rs.getTimestamp("dataHoraInicio") %>
                        </div>
            <%
                    }
                    if (!temAulas) {
            %>
                        <div class="no-data">Nenhuma aula agendada</div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (stmt != null) stmt.close();
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
