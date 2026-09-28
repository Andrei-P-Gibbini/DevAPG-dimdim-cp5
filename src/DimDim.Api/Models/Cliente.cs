using System.ComponentModel.DataAnnotations;

namespace DimDim.Api.Models;

/// <summary>Tabela MASTER: cliente da DimDim.</summary>
public class Cliente
{
    public int Id { get; set; }

    [Required, StringLength(100)]
    public string Nome { get; set; } = string.Empty;

    [Required, EmailAddress, StringLength(150)]
    public string Email { get; set; } = string.Empty;

    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;

    public List<Transacao> Transacoes { get; set; } = new();
}
