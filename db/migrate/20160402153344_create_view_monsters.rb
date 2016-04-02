class CreateViewMonsters < ActiveRecord::Migration
  def self.up
    connection.execute('DROP VIEW IF EXISTS monsters')
    connection.execute <<EOF
CREATE VIEW monsters AS
SELECT c.id as id,
       c.name as name,
       c.type as type,
       max(case when p.name = '#{Property::Names::ELEMENT}' then p.value end) as attribute,
       max(case when p.name = '#{Property::Names::LEVEL}' then p.value end) as level,
       max(case when p.name = '#{Property::Names::RANK}' then p.value end) as rank,
       max(case when p.name = '#{Property::Names::SPECIES}' then p.value end) as species,
       c.description as description,
       max(case when p.name = '#{Property::Names::ATTACK}' then p.value end) as attack,
       max(case when p.name = '#{Property::Names::DEFENSE}' then p.value end) as defense,
       c.serial_number as serial_number
FROM cards c
INNER JOIN properties p ON c.id = p.card_id
WHERE c.id IN (
    SELECT card_id FROM properties
    WHERE name IN (
'#{Property::Names::ELEMENT}',
'#{Property::Names::LEVEL}',
'#{Property::Names::RANK}',
'#{Property::Names::SPECIES}',
'#{Property::Names::ATTACK}',
'#{Property::Names::DEFENSE}'
)
    GROUP BY card_id
    HAVING count(card_id) = 5
  )
AND c.type IN (
  '#{Card::Types::NORMAL}',
  '#{Card::Types::EFFECT}',
  '#{Card::Types::RITUAL}',
  '#{Card::Types::FUSION}',
  '#{Card::Types::SYNCHRO}',
  '#{Card::Types::XYZ}'
)
GROUP BY c.id;
EOF
  end

  def self.down
    connection.execute("DROP VIEW IF EXISTS monsters")
  end
end
