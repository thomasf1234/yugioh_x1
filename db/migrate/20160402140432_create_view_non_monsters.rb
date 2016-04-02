class CreateViewNonMonsters < ActiveRecord::Migration
  def self.up
    connection.execute('DROP VIEW IF EXISTS non_monsters')
    connection.execute <<EOF
CREATE VIEW non_monsters AS
SELECT c.id as id,
       c.name as name,
       c.type as type,
       max(case when p.name = '#{Property::Names::PROPERTY}' then p.value end) as property,
       c.description as description,
       c.serial_number as serial_number
FROM cards c
INNER JOIN properties p ON c.id = p.card_id
WHERE c.id IN (
    SELECT card_id FROM properties
    WHERE name IN ('#{Property::Names::PROPERTY}')
    GROUP BY card_id
    HAVING count(card_id) = 1
  )
AND c.type IN (
  '#{Card::Types::SPELL}',
  '#{Card::Types::TRAP}'
)
GROUP BY c.id;
EOF
  end

  def self.down
    connection.execute('DROP VIEW IF EXISTS non_monsters')
  end
end
