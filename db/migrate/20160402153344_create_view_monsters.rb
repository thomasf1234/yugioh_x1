class CreateViewMonsters < ActiveRecord::Migration
  def self.up
    connection.execute('DROP VIEW IF EXISTS monsters')
    connection.execute <<EOF
CREATE VIEW monsters AS
SELECT c.id as card_id,
       c.name as name,
       c.category as category,
       max(case when p.name = '#{Property::Names::ELEMENT}' then p.value end) as element,
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
AND c.category IN (
  '#{Card::Categories::NORMAL}',
  '#{Card::Categories::EFFECT}',
  '#{Card::Categories::RITUAL}',
  '#{Card::Categories::FUSION}',
  '#{Card::Categories::SYNCHRO}',
  '#{Card::Categories::XYZ}'
)
GROUP BY c.id;
EOF
  end

  def self.down
    connection.execute("DROP VIEW IF EXISTS monsters")
  end
end

# http://stackoverflow.com/questions/2000045/tsql-cast-string-to-integer-or-return-default-value