#!/usr/bin/env ruby

list = []

open('./source.list').each_line do |line|
  next if line =~ /^#/
  line.chomp!
  clazz = Object.const_get(line)

  list = []
  ['', 'public_', 'private_', 'protected_', 'instance_'].each do |type|
    clazz.send(type + 'methods').each do |method|
      list << method.to_s
    end
  end
  list.uniq!
  open('../data/' + clazz.to_s, 'w') do |out|
    list.each do |method|
      out.puts method
    end
  end
end
