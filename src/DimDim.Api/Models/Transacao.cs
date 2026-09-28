using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace DimDim.Api.Models;

/// <summary>Tabela DETAIL: transação de um cliente (FK ClienteId).</summary>
public class Transacao
{
    public int Id { get; set; }

    [Required]
    public int ClienteId { get; set; }

    /// <summary>DEPOSITO, SAQUE ou PIX</summary>
    [Required, RegularExpression("^(DEPOSITO|SAQUE|PIX)$", ErrorMessage = "Tipo deve ser DEPOSITO, SAQUE ou PIX.")]
    [StringLength(20)]
    public string Tipo { get; set; } = string.Empty;

    [Range(0.01, 999999999.99)]
    public decimal Valor { get; set; }

    [StringLength(200)]
    public string? Descricao { get; set; }

    public DateTime DataTransacao { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public Cliente? Cliente { get; set; }
}
