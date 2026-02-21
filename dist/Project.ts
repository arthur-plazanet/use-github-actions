import type { Link } from './Link.js'

export interface Project {
  id: string
  name: string
  pictures: string[]
  description: string
  tags: string[]
  links: Link[]
}
