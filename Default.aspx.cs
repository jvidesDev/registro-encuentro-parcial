using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RegistroEncuentroParcial
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    Cargar(ddlPrograma, "Programas");
                    Cargar(ddlSemestre, "Semestre");
                    Cargar(rblParticipacion, "TipoParticipacion");
                    Cargar(ddlJornada, "Jornada");
                    Cargar(cblTemas, "Tema");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Carga de catálogos: {0}", ex);
                    Mensaje("No fue posible cargar las opciones académicas. Verifica la preparación de la base de datos e intenta nuevamente.", false);
                    btnRegistrar.Enabled = false;
                }
            }
            txtComentarios.Attributes["maxlength"] = "500";
        }

        private static void Cargar(ListControl control, string catalogo)
        {
            control.DataSource = DatosEncuentro.Catalogo(catalogo);
            control.DataValueField = "Id";
            control.DataTextField = "Texto";
            control.DataBind();
            if (control is DropDownList) control.Items.Insert(0, new ListItem("Selecciona una opción", ""));
        }

        private static bool SeleccionValida(ListControl control)
        {
            int valor;
            return control.SelectedItem != null && int.TryParse(control.SelectedValue, out valor) && valor > 0;
        }

        protected void ValidarServidor(object source, ServerValidateEventArgs args)
        {
            if (source == cvTemas) args.IsValid = cblTemas.Items.Cast<ListItem>().Any(x => x.Selected);
            else if (source == cvAcepta) args.IsValid = chkAcepta.Checked;
            else args.IsValid = !string.IsNullOrWhiteSpace(txtNombres.Text) && txtNombres.Text.Trim().Length <= 80
                && !string.IsNullOrWhiteSpace(txtApellidos.Text) && txtApellidos.Text.Trim().Length <= 80
                && txtCorreo.Text.Length <= 160 && Regex.IsMatch(txtCorreo.Text.Trim(), @"\A[^\s@]+@[^\s@]+\.[^\s@]+\z")
                && Regex.IsMatch(txtTelefono.Text, @"\A[0-9]{10}\z")
                && txtComentarios.Text.Length <= 500
                && SeleccionValida(ddlPrograma) && SeleccionValida(ddlSemestre)
                && SeleccionValida(rblParticipacion) && SeleccionValida(ddlJornada);
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            Page.Validate("Registro");
            if (!Page.IsValid)
            {
                Mensaje("No se guardó el registro. Revisa los campos indicados.", false);
                return;
            }
            try
            {
                int[] temas = cblTemas.Items.Cast<ListItem>().Where(x => x.Selected).Select(x => int.Parse(x.Value)).ToArray();
                int numero = DatosEncuentro.Guardar(txtNombres.Text.Trim(), txtApellidos.Text.Trim(), txtCorreo.Text.Trim(),
                    txtTelefono.Text, int.Parse(ddlPrograma.SelectedValue), int.Parse(ddlSemestre.SelectedValue),
                    int.Parse(rblParticipacion.SelectedValue), int.Parse(ddlJornada.SelectedValue), temas, txtComentarios.Text.Trim());
                string resumen = "¡Registro realizado correctamente para " + txtNombres.Text.Trim() + " " + txtApellidos.Text.Trim()
                    + "! Código: EA-" + numero.ToString("D5") + ". Programa: " + ddlPrograma.SelectedItem.Text
                    + ". Semestre: " + ddlSemestre.SelectedItem.Text + ". Participación: " + rblParticipacion.SelectedItem.Text
                    + ". Jornada: " + ddlJornada.SelectedItem.Text + ". Temas: "
                    + string.Join(", ", cblTemas.Items.Cast<ListItem>().Where(x => x.Selected).Select(x => x.Text)) + ".";
                Restablecer();
                Mensaje(resumen, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Registro no guardado: {0}", ex);
                Mensaje("No fue posible guardar la inscripción. No se guardó un registro incompleto. Intenta nuevamente más tarde.", false);
            }
        }

        private void Mensaje(string texto, bool exito)
        {
            lblMensaje.Text = HttpUtility.HtmlEncode(texto);
            lblMensaje.CssClass = exito ? "success" : "failure";
        }

        private void Restablecer()
        {
            txtNombres.Text = txtApellidos.Text = txtCorreo.Text = txtTelefono.Text = txtComentarios.Text = "";
            foreach (var lista in new ListControl[] { ddlPrograma, ddlSemestre, ddlJornada, rblParticipacion, cblTemas }) lista.ClearSelection();
            chkAcepta.Checked = false;
            foreach (IValidator validador in Validators) validador.IsValid = true;
            lblMensaje.Text = "";
            lblMensaje.CssClass = "";
        }

        protected void btnLimpiar_Click(object sender, EventArgs e) { Restablecer(); }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            Response.Redirect("Cancelado.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
