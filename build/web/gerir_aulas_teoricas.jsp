<%-- 
    Document   : gerir_aulas_teoricas
    Created on : 04/03/2026, 11:08:36
    Author     : pmnch
--%>

<%-- Document : gerir_aulas_teoricas --%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String tipoUser = (String) session.getAttribute("tipo");
    if (!"Admin".equals(tipoUser) && !"Professor".equals(tipoUser)) {
        response.sendRedirect("login.jsp"); return;
    }
    String username = (String) session.getAttribute("username");
    boolean isAdmin = "Admin".equals(tipoUser);
    String dashboardLink = isAdmin ? "dashboard.jsp" : "dashboard_professor.jsp";
    String iconeUser = isAdmin ? "user-shield" : "chalkboard-teacher";

    // POST
    if ("POST".equals(request.getMethod())) {
        String acao = request.getParameter("acao");
        Connection conn2 = null;
        try {
            conn2 = ConexaoBD.getConnection();
            if (("acesso".equals(acao) || "codigo".equals(acao)) && !isAdmin) {
                response.sendRedirect("gerir_aulas_teoricas.jsp?idAluno=" + request.getParameter("idAluno") + "&erro=semPermissao");
                return;
            }
            if ("adicionar".equals(acao)) {
                int idAluno = Integer.parseInt(request.getParameter("idAluno"));
                String data  = request.getParameter("data");
                String hora  = request.getParameter("hora");
                String estado = request.getParameter("estado");
                String obs   = request.getParameter("observacoes");
                String duracaoStr = request.getParameter("duracao");
                int duracao = duracaoStr != null ? Integer.parseInt(duracaoStr) : 1;
                PreparedStatement ps = conn2.prepareStatement(
                    "INSERT INTO aula_teorica (idAluno, data, hora, duracao, estado, observacoes) VALUES (?,?,?,?,?,?)");
                ps.setInt(1, idAluno);
                ps.setString(2, data);
                ps.setString(3, hora);
                ps.setInt(4, duracao);
                ps.setString(5, estado);
                ps.setString(6, obs);
                ps.executeUpdate();
                ps.close();
            } else if ("eliminar".equals(acao)) {
                int idAula = Integer.parseInt(request.getParameter("idAula"));
                PreparedStatement ps = conn2.prepareStatement("DELETE FROM aula_teorica WHERE id=?");
                ps.setInt(1, idAula);
                ps.executeUpdate();
                ps.close();
            } else if ("acesso".equals(acao)) {
                int idAluno = Integer.parseInt(request.getParameter("idAluno"));
                int acesso  = Integer.parseInt(request.getParameter("acesso"));
                PreparedStatement ps = conn2.prepareStatement("UPDATE aluno SET acessoConducao=? WHERE id=?");
                ps.setInt(1, acesso); ps.setInt(2, idAluno);
                ps.executeUpdate(); ps.close();
            } else if ("codigo".equals(acao)) {
                int idAluno  = Integer.parseInt(request.getParameter("idAluno"));
                int aprovado = Integer.parseInt(request.getParameter("aprovado"));
                PreparedStatement ps = conn2.prepareStatement("UPDATE aluno SET aprovadoCodigo=? WHERE id=?");
                ps.setInt(1, aprovado); ps.setInt(2, idAluno);
                ps.executeUpdate(); ps.close();
            }
        } catch(Exception e){ e.printStackTrace(); }
        finally { try{ if(conn2!=null) conn2.close(); }catch(Exception e){} }
        response.sendRedirect("gerir_aulas_teoricas.jsp?idAluno=" + request.getParameter("idAluno"));
        return;
    }

    // GET
    int idAlunoSel = 0;
    String paramId = request.getParameter("idAluno");
    if (paramId != null) try { idAlunoSel = Integer.parseInt(paramId); } catch(Exception e){}

    Connection conn = null;
    List<String[]> alunos = new ArrayList<>();
    List<String[]> aulasTeoricas = new ArrayList<>();
    String[] alunoSel = null;
    int totalTeorica = 0, totalConducao = 0;

    try {
        conn = ConexaoBD.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, nome, acessoConducao, aprovadoCodigo FROM aluno ORDER BY nome");
        ResultSet rs = ps.executeQuery();
        while(rs.next()) {
            alunos.add(new String[]{
                rs.getString("id"), rs.getString("nome"),
                rs.getString("acessoConducao"), rs.getString("aprovadoCodigo")
            });
        }
        rs.close(); ps.close();

        if (idAlunoSel > 0) {
            ps = conn.prepareStatement(
                "SELECT id, nome, acessoConducao, aprovadoCodigo FROM aluno WHERE id=?");
            ps.setInt(1, idAlunoSel); rs = ps.executeQuery();
            if(rs.next()) {
                alunoSel = new String[]{
                    rs.getString("id"), rs.getString("nome"),
                    rs.getString("acessoConducao"), rs.getString("aprovadoCodigo")
                };
            }
            rs.close(); ps.close();

            ps = conn.prepareStatement(
                "SELECT id, data, hora, duracao, estado, observacoes FROM aula_teorica WHERE idAluno=? ORDER BY data DESC, hora DESC");
            ps.setInt(1, idAlunoSel); rs = ps.executeQuery();
            while(rs.next()) {
                aulasTeoricas.add(new String[]{
                    rs.getString("id"), rs.getString("data"),
                    rs.getString("hora"), rs.getString("duracao"),
                    rs.getString("estado"), rs.getString("observacoes")
                });
            }
            totalTeorica = aulasTeoricas.size();
            rs.close(); ps.close();

            ps = conn.prepareStatement(
                "SELECT COUNT(*) as total FROM aula_conducao WHERE idAluno=? AND estado != 'cancelada'");
            ps.setInt(1, idAlunoSel); rs = ps.executeQuery();
            if(rs.next()) totalConducao = rs.getInt("total");
            rs.close(); ps.close();
        }
    } catch(Exception e){ e.printStackTrace(); }
    finally { try{ if(conn!=null) conn.close(); }catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Gerir Aulas Teóricas - Drive School</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); background-attachment:fixed; color:white; min-height:100vh; }
        .topbar { background:rgba(0,0,0,0.4); backdrop-filter:blur(10px); border-bottom:1px solid rgba(255,193,7,0.2); padding:12px 30px; display:flex; justify-content:space-between; align-items:center; }
        .topbar-left { display:flex; align-items:center; gap:18px; }
        .topbar-left img { height:46px; filter:drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display:flex; align-items:center; gap:8px; font-size:.9rem; }
        .user-info i { color:#FFC107; }
        .btn-voltar { background:rgba(255,255,255,.1); color:white; padding:8px 20px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; font-size:.9rem; }
        .btn-voltar:hover { border-color:#FFC107; color:#FFC107; }
        .wrap { max-width:1100px; margin:0 auto; padding:30px 20px; }
        .page-title { font-size:1.8rem; font-weight:800; margin-bottom:25px; display:flex; align-items:center; gap:12px; }
        .page-title i { color:#FFC107; }
        .grid-layout { display:grid; grid-template-columns:280px 1fr; gap:22px; align-items:start; }
        .card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.2); border-radius:18px; padding:24px; }
        .card-title { font-size:.78rem; text-transform:uppercase; letter-spacing:1px; color:#FFC107; font-weight:700; margin-bottom:16px; display:flex; align-items:center; gap:8px; }
        .card-title::after { content:''; flex:1; height:1px; background:rgba(255,193,7,.2); }
        .aluno-item { padding:10px 12px; border-radius:10px; cursor:pointer; transition:all .2s; display:flex; justify-content:space-between; align-items:center; margin-bottom:6px; border:1px solid transparent; }
        .aluno-item:hover { background:rgba(255,193,7,.1); border-color:rgba(255,193,7,.2); }
        .aluno-item.ativo { background:rgba(255,193,7,.15); border-color:#FFC107; }
        .aluno-item .nome { font-size:.9rem; font-weight:600; }
        .badge { font-size:.68rem; padding:3px 8px; border-radius:8px; font-weight:700; }
        .badge-verde { background:rgba(40,167,69,.3); color:#a8f0b8; border:1px solid rgba(40,167,69,.4); }
        .badge-cinza { background:rgba(255,255,255,.1); color:rgba(255,255,255,.5); border:1px solid rgba(255,255,255,.15); }
        .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:22px; }
        .stat-box { background:rgba(255,255,255,.05); border:1px solid rgba(255,193,7,.15); border-radius:14px; padding:18px; text-align:center; }
        .stat-box .num { font-size:2rem; font-weight:800; color:#FFC107; }
        .stat-box .lbl { font-size:.75rem; color:rgba(255,255,255,.6); text-transform:uppercase; letter-spacing:.8px; margin-top:4px; }
        .acoes-row { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:22px; }
        .btn-acao { padding:9px 18px; border-radius:20px; font-size:.85rem; font-weight:700; cursor:pointer; border:none; display:inline-flex; align-items:center; gap:7px; transition:all .3s; font-family:'Work Sans',sans-serif; }
        .btn-acesso-on  { background:linear-gradient(135deg,#28a745,#20c040); color:white; }
        .btn-acesso-off { background:rgba(220,53,69,.3); color:#f5a0a8; border:1px solid rgba(220,53,69,.5); }
        .btn-codigo-on  { background:linear-gradient(135deg,#FFC107,#FFB300); color:#1a3a4d; }
        .btn-codigo-off { background:rgba(255,255,255,.1); color:white; border:1px solid rgba(255,255,255,.2); }
        .form-inline-slots { display:grid; grid-template-columns:1fr 1fr 1fr auto; gap:10px; align-items:end; margin-bottom:20px; }
        .form-inline-slots .fg label { font-size:.78rem; color:rgba(255,255,255,.7); margin-bottom:5px; display:block; }
        .form-inline-slots input, .form-inline-slots select { width:100%; padding:10px 12px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.08); color:white; font-family:'Work Sans',sans-serif; font-size:.88rem; }
        .form-inline-slots input:focus, .form-inline-slots select:focus { outline:none; border-color:#FFC107; }
        .form-inline-slots select option { background:#1a3a4d; }
        .btn-add { background:linear-gradient(135deg,#FFC107,#FFB300); color:#1a3a4d; padding:10px 20px; border-radius:10px; border:none; font-weight:700; cursor:pointer; font-family:'Work Sans',sans-serif; white-space:nowrap; display:flex; align-items:center; gap:7px; }
        table { width:100%; border-collapse:collapse; }
        th { background:linear-gradient(135deg,#1a3a4d,#800020); padding:12px 14px; text-align:left; font-size:.8rem; text-transform:uppercase; letter-spacing:.8px; color:rgba(255,255,255,.8); }
        td { padding:12px 14px; border-bottom:1px solid rgba(255,255,255,.06); font-size:.9rem; }
        tr:hover td { background:rgba(255,193,7,.05); }
        .estado-realizada { color:#a8f0b8; }
        .estado-falta { color:#f5a0a8; }
        .btn-del { background:rgba(220,53,69,.25); color:#f5a0a8; border:1px solid rgba(220,53,69,.4); padding:5px 12px; border-radius:8px; cursor:pointer; font-size:.8rem; font-family:'Work Sans',sans-serif; transition:all .2s; }
        .btn-del:hover { background:rgba(220,53,69,.4); }
        .empty-state { text-align:center; padding:40px; color:rgba(255,255,255,.4); }
        .progresso-bar { background:rgba(255,255,255,.1); border-radius:10px; height:8px; margin-top:8px; overflow:hidden; }
        .progresso-fill { height:100%; border-radius:10px; background:linear-gradient(90deg,#FFC107,#FFB300); transition:width .5s; }
        .progresso-fill.completo { background:linear-gradient(90deg,#28a745,#20c040); }
        .alerta-box { background:rgba(255,193,7,.1); border:1px solid rgba(255,193,7,.3); border-radius:12px; padding:14px 18px; margin-bottom:18px; font-size:.88rem; color:rgba(255,255,255,.85); }
        .alerta-box i { color:#FFC107; margin-right:8px; }
        .sem-permissao { color:rgba(255,255,255,.5); font-size:.88rem; padding:8px 0; }
        .grupo-label { font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.8px; padding:6px 8px; border-radius:8px; margin-bottom:8px; display:flex; align-items:center; gap:6px; }
        .grupo-pendente { background:rgba(255,193,7,.1); color:#FFC107; border:1px solid rgba(255,193,7,.2); }
        .grupo-aprovado { background:rgba(40,167,69,.1); color:#a8f0b8; border:1px solid rgba(40,167,69,.25); }
        .grupo-vazio { font-size:.8rem; color:rgba(255,255,255,.3); padding:6px 10px; font-style:italic; }
        .grupo-label { font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.8px; padding:6px 8px; border-radius:8px; margin-bottom:8px; display:flex; align-items:center; gap:6px; }
        .grupo-pendente { background:rgba(255,193,7,.1); color:#FFC107; border:1px solid rgba(255,193,7,.2); }
        .grupo-aprovado { background:rgba(40,167,69,.1); color:#a8f0b8; border:1px solid rgba(40,167,69,.25); }
        .grupo-vazio { font-size:.8rem; color:rgba(255,255,255,.3); padding:6px 10px; font-style:italic; }
        .sem-permissao i { color:rgba(255,193,7,.4); margin-right:8px; }
        @media(max-width:900px){ .grid-layout{ grid-template-columns:1fr; } .form-inline{ grid-template-columns:1fr 1fr; } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="<%= dashboardLink %>">
                <img src="image/logo_mini.png" alt="Drive School">
            </a>
            <div class="user-info">
                <i class="fa fa-<%= iconeUser %>"></i>
                <span><strong><%= username %></strong> (<%= tipoUser %>)</span>
            </div>
        </div>
        <a href="<%= dashboardLink %>" class="btn-voltar">
            <i class="fa fa-arrow-left"></i>Dashboard
        </a>
    </div>

    <div class="wrap">
        <div class="page-title"><i class="fa fa-chalkboard"></i>Gerir Aulas Teóricas</div>

        <div class="grid-layout">
            <!-- LISTA ALUNOS -->
            <div class="card">
                <div class="card-title"><i class="fa fa-users"></i> Alunos</div>

                <%-- Grupo 1: Sem exame de código --%>
                <div class="grupo-label grupo-pendente">
                    <i class="fa fa-clock"></i> Sem exame de código
                </div>
                <% boolean algumPendente = false;
                   for (String[] a : alunos) {
                    if ("1".equals(a[3])) continue; // só os não aprovados
                    algumPendente = true;
                    boolean temAcessoItem = "1".equals(a[2]);
                    String itemClass = a[0].equals(String.valueOf(idAlunoSel)) ? "aluno-item ativo" : "aluno-item";
                    String badgeClass = temAcessoItem ? "badge badge-verde" : "badge badge-cinza";
                    String badgeText = temAcessoItem ? "✓ Condução" : "Teóricas";
                %>
                <div class="<%= itemClass %>" onclick="location.href='gerir_aulas_teoricas.jsp?idAluno=<%= a[0] %>'">
                    <span class="nome"><%= a[1] %></span>
                    <span class="<%= badgeClass %>"><%= badgeText %></span>
                </div>
                <% } %>
                <% if (!algumPendente) { %>
                <div class="grupo-vazio">Nenhum aluno pendente</div>
                <% } %>

                <%-- Grupo 2: Aprovados no código --%>
                <div class="grupo-label grupo-aprovado" style="margin-top:18px;">
                    <i class="fa fa-check-circle"></i> Aprovados no código
                </div>
                <% boolean algumAprovado = false;
                   for (String[] a : alunos) {
                    if (!"1".equals(a[3])) continue; // só os aprovados
                    algumAprovado = true;
                    boolean temAcessoItem = "1".equals(a[2]);
                    String itemClass = a[0].equals(String.valueOf(idAlunoSel)) ? "aluno-item ativo" : "aluno-item";
                    String badgeClass = temAcessoItem ? "badge badge-verde" : "badge badge-cinza";
                    String badgeText = temAcessoItem ? "✓ Condução" : "Teóricas";
                %>
                <div class="<%= itemClass %>" onclick="location.href='gerir_aulas_teoricas.jsp?idAluno=<%= a[0] %>'">
                    <span class="nome"><%= a[1] %></span>
                    <span class="<%= badgeClass %>"><%= badgeText %></span>
                </div>
                <% } %>
                <% if (!algumAprovado) { %>
                <div class="grupo-vazio">Nenhum aluno aprovado ainda</div>
                <% } %>
            </div>

            <!-- PAINEL DIREITO -->
            <div>
                <% if (alunoSel == null) { %>
                    <div class="card">
                        <div class="empty-state">
                            <i class="fa fa-hand-pointer fa-3x" style="color:rgba(255,193,7,.3);margin-bottom:16px;"></i>
                            <p>Seleciona um aluno da lista</p>
                        </div>
                    </div>
                <% } else {
                    boolean temAcesso = "1".equals(alunoSel[2]);
                    boolean aprovadoCod = "1".equals(alunoSel[3]);
                    int limite1 = aprovadoCod ? 30 : 15;
                    int pctTeorica = Math.min(100, totalTeorica * 5);
                    int pctConducao = totalConducao > 0 ? Math.min(100, totalConducao * 100 / limite1) : 0;
                    String classTeorica = totalTeorica >= 20 ? "progresso-fill completo" : "progresso-fill";
                    String classConducao = totalConducao >= limite1 ? "progresso-fill completo" : "progresso-fill";
                    String btnAcessoClass = temAcesso ? "btn-acao btn-acesso-off" : "btn-acao btn-acesso-on";
                    String btnAcessoIcon = temAcesso ? "lock" : "unlock";
                    String btnAcessoText = temAcesso ? "Revogar Acesso à Condução" : "Dar Acesso à Condução";
                    String btnCodigoClass = aprovadoCod ? "btn-acao btn-acesso-off" : "btn-acao btn-codigo-on";
                    String btnCodigoText = aprovadoCod ? "Revogar Aprovação Código" : "Marcar Aprovado no Código";
                    String dataHoje = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
                %>
                <!-- STATS -->
                <div class="stats-row">
                    <div class="stat-box">
                        <div class="num"><%= totalTeorica %>/20</div>
                        <div class="lbl">Aulas Teóricas</div>
                        <div class="progresso-bar"><div class="<%= classTeorica %>" style="width:<%= pctTeorica %>%"></div></div>
                    </div>
                    <div class="stat-box">
                        <div class="num"><%= totalConducao %>/<%= limite1 %></div>
                        <div class="lbl">Aulas Condução</div>
                        <div class="progresso-bar"><div class="<%= classConducao %>" style="width:<%= pctConducao %>%"></div></div>
                    </div>
                    <div class="stat-box">
                        <div class="num" style="font-size:1.3rem"><%= aprovadoCod ? "✓" : "✗" %></div>
                        <div class="lbl">Exame Código</div>
                    </div>
                </div>

                <!-- AVISO 20 AULAS -->
                <% if (totalTeorica >= 20 && !temAcesso) { %>
                <div class="alerta-box">
                    <i class="fa fa-info-circle"></i>
                    Este aluno já tem <strong>20 aulas teóricas</strong>! Podes dar acesso às aulas de condução.
                </div>
                <% } %>

                <!-- CONTROLO DE ACESSO -->
                <div class="card" style="margin-bottom:22px;">
                    <div class="card-title"><i class="fa fa-sliders-h"></i> Controlo de Acesso</div>
                    <% if (isAdmin) { %>
                    <div class="acoes-row">
                        <form method="POST">
                            <input type="hidden" name="acao" value="acesso">
                            <input type="hidden" name="idAluno" value="<%= alunoSel[0] %>">
                            <input type="hidden" name="acesso" value="<%= temAcesso ? "0" : "1" %>">
                            <button type="submit" class="<%= btnAcessoClass %>">
                                <i class="fa fa-<%= btnAcessoIcon %>"></i><%= btnAcessoText %>
                            </button>
                        </form>
                        <form method="POST">
                            <input type="hidden" name="acao" value="codigo">
                            <input type="hidden" name="idAluno" value="<%= alunoSel[0] %>">
                            <input type="hidden" name="aprovado" value="<%= aprovadoCod ? "0" : "1" %>">
                            <button type="submit" class="<%= btnCodigoClass %>">
                                <i class="fa fa-graduation-cap"></i><%= btnCodigoText %>
                            </button>
                        </form>
                    </div>
                    <% } else { %>
                    <div class="sem-permissao">
                        <i class="fa fa-lock"></i>Apenas o administrador pode dar acesso às aulas de condução.
                    </div>
                    <% } %>
                </div>

                <!-- ADICIONAR AULA TEÓRICA -->
                <div class="card">
                    <div class="card-title"><i class="fa fa-plus"></i> Registar Aula Teórica</div>
                    <form method="POST" onsubmit="return validarDiaUtil()">
                        <input type="hidden" name="acao" value="adicionar">
                        <input type="hidden" name="idAluno" value="<%= alunoSel[0] %>">
                        <input type="hidden" name="estado" value="realizada">
                        <input type="hidden" name="duracao" value="1">
                        <div class="form-inline-slots">
                            <div class="fg">
                                <label>Data <span style="color:rgba(255,255,255,.4);font-size:.72rem">(dias úteis)</span></label>
                                <input type="date" name="data" id="dataAula" required value="<%= dataHoje %>" onchange="verificarDiaUtil(this)">
                            </div>
                            <div class="fg">
                                <label>Slot</label>
                                <select name="hora" required>
                                    <option value="10:00:00">10:00 — 11:00</option>
                                    <option value="11:00:00">11:00 — 12:00</option>
                                    <option value="17:00:00">17:00 — 18:00</option>
                                    <option value="18:00:00">18:00 — 19:00</option>
                                </select>
                            </div>
                            <div class="fg">
                                <label>Observações</label>
                                <input type="text" name="observacoes" placeholder="Opcional">
                            </div>
                            <button type="submit" class="btn-add"><i class="fa fa-plus"></i>Registar</button>
                        </div>
                        <div id="aviso-fds" style="display:none;margin-top:10px;background:rgba(220,53,69,.2);border:1px solid rgba(220,53,69,.5);border-radius:10px;padding:10px 14px;color:#f5a0a8;font-size:.85rem;">
                            <i class="fa fa-exclamation-triangle" style="margin-right:7px;"></i>
                            As aulas teóricas são apenas em dias úteis (segunda a sexta)!
                        </div>
                    </form>
                    <script>
                    function verificarDiaUtil(input) {
                        var data = new Date(input.value + 'T00:00:00');
                        var diaSemana = data.getDay();
                        var aviso = document.getElementById('aviso-fds');
                        if (diaSemana === 0 || diaSemana === 6) {
                            aviso.style.display = 'block';
                            input.style.borderColor = '#f44336';
                        } else {
                            aviso.style.display = 'none';
                            input.style.borderColor = '#FFC107';
                        }
                    }
                    function validarDiaUtil() {
                        var input = document.getElementById('dataAula');
                        if (!input.value) return true;
                        var data = new Date(input.value + 'T00:00:00');
                        if (data.getDay() === 0 || data.getDay() === 6) {
                            alert('As aulas teóricas são apenas de segunda a sexta!');
                            return false;
                        }
                        return true;
                    }
                    </script>

                    <% if (aulasTeoricas.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fa fa-book fa-2x" style="margin-bottom:10px;opacity:.3"></i>
                            <p>Sem aulas teóricas registadas</p>
                        </div>
                    <% } else { %>
                    <table>
                        <tr><th>#</th><th>Data</th><th>Slot</th><th>Observações</th><th></th></tr>
                        <% int num = 1; for(String[] at : aulasTeoricas) {
                            String horaInicio = at[2] != null ? at[2].substring(0,5) : "";
                            // Calcular hora fim (+1h)
                            String horaFim = "";
                            if (at[2] != null) {
                                int hh = Integer.parseInt(at[2].substring(0,2)) + 1;
                                horaFim = String.format("%02d:00", hh);
                            }
                            String slotTexto = horaInicio + " — " + horaFim;
                            String obsTexto = at[5] != null ? at[5] : "-";
                        %>
                        <tr>
                            <td><%= num++ %></td>
                            <td><%= at[1] %></td>
                            <td><%= slotTexto %></td>
                            <td><%= obsTexto %></td>
                            <td>
                                <form method="POST" style="display:inline" onsubmit="return confirm('Eliminar esta aula?')">
                                    <input type="hidden" name="acao" value="eliminar">
                                    <input type="hidden" name="idAula" value="<%= at[0] %>">
                                    <input type="hidden" name="idAluno" value="<%= alunoSel[0] %>">
                                    <button type="submit" class="btn-del"><i class="fa fa-trash"></i></button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </table>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>


