using DimDim.Api.Data;
using DimDim.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DimDim.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransacoesController : ControllerBase
{
    private readonly AppDbContext _db;

    public TransacoesController(AppDbContext db) => _db = db;

    // GET api/transacoes  ou  api/transacoes?clienteId=1
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Transacao>>> GetAll([FromQuery] int? clienteId)
    {
        var query = _db.Transacoes.AsNoTracking().AsQueryable();
        if (clienteId.HasValue) query = query.Where(t => t.ClienteId == clienteId.Value);
        return Ok(await query.OrderByDescending(t => t.DataTransacao).ToListAsync());
    }

    // GET api/transacoes/1
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Transacao>> GetById(int id)
    {
        var transacao = await _db.Transacoes.AsNoTracking().FirstOrDefaultAsync(t => t.Id == id);
        if (transacao is null) return NotFound();
        return Ok(transacao);
    }

    // POST api/transacoes
    [HttpPost]
    public async Task<ActionResult<Transacao>> Create(Transacao transacao)
    {
        if (!await _db.Clientes.AnyAsync(c => c.Id == transacao.ClienteId))
            return BadRequest(new { erro = "Cliente informado não existe." });

        transacao.Id = 0;
        transacao.DataTransacao = DateTime.UtcNow;

        _db.Transacoes.Add(transacao);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = transacao.Id }, transacao);
    }

    // PUT api/transacoes/1
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, Transacao input)
    {
        var transacao = await _db.Transacoes.FindAsync(id);
        if (transacao is null) return NotFound();

        if (!await _db.Clientes.AnyAsync(c => c.Id == input.ClienteId))
            return BadRequest(new { erro = "Cliente informado não existe." });

        transacao.ClienteId = input.ClienteId;
        transacao.Tipo = input.Tipo;
        transacao.Valor = input.Valor;
        transacao.Descricao = input.Descricao;
        await _db.SaveChangesAsync();

        return NoContent();
    }

    // DELETE api/transacoes/1
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var transacao = await _db.Transacoes.FindAsync(id);
        if (transacao is null) return NotFound();

        _db.Transacoes.Remove(transacao);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}
