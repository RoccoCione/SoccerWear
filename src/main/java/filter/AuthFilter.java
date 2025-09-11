package filter;

import model.UtenteBean;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter("/admin/*")
public class AuthFilter implements Filter {
  @Override public void init(FilterConfig filterConfig) {}

  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest  request  = (HttpServletRequest) req;
    HttpServletResponse response = (HttpServletResponse) res;

    // risorse statiche dentro /admin? (se non ne hai, puoi togliere)
    String uri = request.getRequestURI();
    if (uri.startsWith(request.getContextPath() + "/admin/assets/") ||
        uri.startsWith(request.getContextPath() + "/admin/static/")) {
      chain.doFilter(req, res);
      return;
    }

    HttpSession session = request.getSession(false);
    UtenteBean u = (session == null) ? null : (UtenteBean) session.getAttribute("utente");
    boolean isAdmin = (u != null && "admin".equalsIgnoreCase(u.getRuolo()));

    if (isAdmin) {
      chain.doFilter(req, res);
      return;
    }

    // Se è una chiamata AJAX/JSON -> 403 JSON
    String accept = String.valueOf(request.getHeader("Accept")).toLowerCase();
    boolean wantsJson = accept.contains("application/json") ||
                        "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

    if (wantsJson) {
      response.setStatus(HttpServletResponse.SC_FORBIDDEN);
      response.setContentType("application/json; charset=UTF-8");
      response.getWriter().write("{\"success\":false,\"error\":\"Forbidden\"}");
    } else {
      // redirect a home (o pagina login) con flash
      session = (session != null) ? session : request.getSession(true);
      session.setAttribute("flashError", "Devi essere amministratore per accedere.");
      response.sendRedirect(request.getContextPath() + "/home.jsp");
    }
  }

  @Override public void destroy() {}
}
